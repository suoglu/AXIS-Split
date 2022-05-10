`timescale 1 ns / 1 ps
/* ------------------------------------------------ *
 * Title       : AXI-Stream Spliter                 *
 * Project     : AXI-Stream Spliter                 *
 * ------------------------------------------------ *
 * File        : AXIS_Split_v1_0.v                  *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 10/05/2022                         *
 * ------------------------------------------------ *
 * Description : Splits one AXI-Stream transmission *
 *               to two                             *
 * ------------------------------------------------ *
 * Revisions                                        *
 *     v1      : Inital version                     *
 * ------------------------------------------------ */

  module AXIS_Split_v1_0 #
  (
    parameter BUFFER_MODE = "NONE", //"HALF", "FULL"
    parameter MSH_FIRST = 1,

    parameter ENABLE_TSTRB = 0,
    parameter ENABLE_TLAST = 0,

    // Parameters of Axi Slave Bus Interface S_AXIS
    parameter C_S_AXIS_TDATA_WIDTH  = 32,
    parameter C_M_AXIS_TDATA_WIDTH  = C_S_AXIS_TDATA_WIDTH/2
  )(
    input axis_aclk,
    input axis_aresetn,

    // Ports of Axi Slave Bus Interface S_AXIS
    output reg s_axis_tready,
    input  s_axis_tvalid,
    input [C_S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata,
    input  s_axis_tlast,
    input [(C_S_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tstrb,

    // Ports of Axi Master Bus Interface M_AXIS
    input   m_axis_tready,
    output reg m_axis_tvalid,
    output reg [C_M_AXIS_TDATA_WIDTH-1:0] m_axis_tdata,
    output  m_axis_tlast,
    output reg [(C_M_AXIS_TDATA_WIDTH/8)-1:0] m_axis_tstrb
  );
    localparam FA7A1E33 = 32'hFA7A1E33;
    wire master_handshake = m_axis_tready & m_axis_tvalid;
    wire  slave_handshake = s_axis_tready & s_axis_tvalid;
    reg buffer_invalid;


    //State Control
    localparam FIRST = 1'b0,
                LAST = 1'b1;
    reg state;
    wire inFirst = (state == FIRST);
    wire inLast  = (state == LAST);


    wire state_next = (inLast) ? FIRST : LAST;
    wire state_advance = (BUFFER_MODE == "FULL") ? (buffer_invalid | inLast) & master_handshake:
                                                                               master_handshake;

    always@(posedge axis_aclk) begin
      if(~axis_aresetn) begin
        state <= FIRST;
      end else begin
        state <= (state_advance) ? state_next : state;
      end
    end


    //Buffer Control
    localparam BUFFER_ENABLE = (BUFFER_MODE == "HALF")|(BUFFER_MODE == "FULL");
    wire update_buffers = (!BUFFER_ENABLE) ?       1'b0      : 
                   (BUFFER_MODE == "FULL") ?  slave_handshake: 
                                   inFirst & master_handshake;
    generate
      if(BUFFER_MODE == "FULL") begin
        always@(posedge axis_aclk) begin
          if(~axis_aresetn) begin
            buffer_invalid <= 1;
          end else case(buffer_invalid)
            1: buffer_invalid <= ~update_buffers;
            0: buffer_invalid <= ~(inLast & master_handshake);
          endcase
        end
      end
    endgenerate
    
    
    //Data Bus
    reg [C_M_AXIS_TDATA_WIDTH-1:0] firstHalf, lastHalf; //Combinational
    always@* begin
      if(MSH_FIRST) begin
        {firstHalf, lastHalf} = s_axis_tdata;
      end else begin
        {lastHalf, firstHalf} = s_axis_tdata;
      end
    end
    reg [C_M_AXIS_TDATA_WIDTH-1:0] firstHalf_buff, lastHalf_buff;
    generate
      if(BUFFER_MODE == "FULL") begin
        always@(posedge axis_aclk) begin
          if(~axis_aresetn) begin
            firstHalf_buff <= FA7A1E33; //!Should never be read
          end else if(update_buffers) begin
            firstHalf_buff <= firstHalf;
          end
        end
      end
      if(BUFFER_ENABLE) begin
        always@(posedge axis_aclk) begin
          if(~axis_aresetn) begin
            lastHalf_buff <= FA7A1E33; //!Should never be read
          end else if(update_buffers) begin
            lastHalf_buff <= lastHalf;
          end
        end
      end
    endgenerate
    always@* begin
      case(state)
        FIRST: begin
          if(BUFFER_MODE == "FULL") begin
            m_axis_tdata = (master_handshake) ? firstHalf : firstHalf_buff;
          end else begin
            m_axis_tdata = firstHalf;
          end
        end
        LAST: begin
          m_axis_tdata = (BUFFER_ENABLE) ? lastHalf_buff : lastHalf;
        end
        default: m_axis_tdata = FA7A1E33; //!Should never be here
      endcase
    end


    //TLast
    reg tlast_buff;
    generate
      if(ENABLE_TLAST) begin
        if(BUFFER_ENABLE) begin
          always@(posedge axis_aclk) begin
            if(~axis_aresetn) begin
              tlast_buff <= 0;
            end else if(update_buffers) begin
              tlast_buff <= s_axis_tlast;
            end
          end
        end
        assign m_axis_tlast = (inFirst) ? 1'b0 : 
                       ((BUFFER_ENABLE) ? tlast_buff : s_axis_tlast);
      end
    endgenerate


    //TStrb
    reg [(C_M_AXIS_TDATA_WIDTH/8)-1:0] tstrb_First, tstrb_Last; //Combinational
    always@* begin
      if(MSH_FIRST) begin
        {tstrb_First, tstrb_Last} = s_axis_tstrb;
      end else begin
        {tstrb_Last, tstrb_First} = s_axis_tstrb;
      end
    end
    reg [(C_M_AXIS_TDATA_WIDTH/8)-1:0] tstrb_First_buff, tstrb_Last_buff;
    generate
      if(ENABLE_TSTRB) begin
        if(BUFFER_MODE == "FULL") begin
          always@(posedge axis_aclk) begin
            if(~axis_aresetn) begin
              tstrb_First_buff <= 0; //!Should never be read
            end else if(update_buffers) begin
              tstrb_First_buff <= tstrb_First;
            end
          end
        end
        if(BUFFER_ENABLE) begin
          always@(posedge axis_aclk) begin
            if(~axis_aresetn) begin
              tstrb_Last_buff <= 0; //!Should never be read
            end else if(update_buffers) begin
              tstrb_Last_buff <= tstrb_Last;
            end
          end
        end
      end
      always@* begin
        case(state)
          FIRST: begin
            if(BUFFER_MODE == "FULL") begin
              m_axis_tstrb = (master_handshake) ? tstrb_First : tstrb_First_buff;
            end else begin
              m_axis_tstrb = tstrb_First;
            end
          end
          LAST: begin
            m_axis_tstrb = (BUFFER_ENABLE) ? tstrb_Last_buff : tstrb_Last;
          end
          default: m_axis_tstrb = 0; //!Should never be here
        endcase
      end
    endgenerate


    //Slave Ready
    always@* begin
      if(BUFFER_MODE == "FULL") begin //Slave Handshake as buffers are load
        s_axis_tready = buffer_invalid;
      end else begin //Slave Handshake as master is done
        s_axis_tready = inLast & master_handshake;
      end
    end


    //Master valid
    always@* begin
      if(BUFFER_MODE == "FULL") begin //Slave Handshake as buffers are load
        m_axis_tvalid = ~buffer_invalid | s_axis_tvalid;
      end else begin //Slave Handshake as master is done
        m_axis_tvalid = inLast | s_axis_tvalid;
      end
    end
  endmodule

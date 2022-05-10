`timescale 1 ns / 1 ps
/* ------------------------------------------------ *
 * Title       : AXI-Stream Spliter Testbench       *
 * Project     : AXI-Stream Spliter                 *
 * ------------------------------------------------ *
 * File        : tb.v                               *
 * Author      : Yigit Suoglu                       *
 * Last Edit   : 10/05/2022                         *
 * ------------------------------------------------ *
 * Description : Testbench for AXI-Stream splitter  *
 * ------------------------------------------------ */

module tb();
  parameter C_S_AXIS_TDATA_WIDTH  = 32;
  parameter C_M_AXIS_TDATA_WIDTH  = C_S_AXIS_TDATA_WIDTH/2;

  wire s_axis_tready_nb, s_axis_tready_hb, s_axis_tready_fb;
  reg s_axis_tvalid_nb = 0;
  reg s_axis_tvalid_hb = 0;
  reg s_axis_tvalid_fb = 0;
  reg [C_S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata_nb = 32'h12345678;
  reg [C_S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata_hb = 32'h12345678;
  reg [C_S_AXIS_TDATA_WIDTH-1:0] s_axis_tdata_fb = 32'h12345678;
  reg s_axis_tlast_nb = 0;
  reg s_axis_tlast_hb = 0;
  reg s_axis_tlast_fb = 0;
  reg [(C_S_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tstrb_nb = 8'hF0;
  reg [(C_S_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tstrb_hb = 8'hF0;
  reg [(C_S_AXIS_TDATA_WIDTH/8)-1:0] s_axis_tstrb_fb = 8'hF0;
  reg m_axis_tready_nb = 1;
  reg m_axis_tready_hb = 1;
  reg m_axis_tready_fb = 1;
  wire m_axis_tvalid_nb, m_axis_tvalid_hb, m_axis_tvalid_fb;
  wire [C_M_AXIS_TDATA_WIDTH-1:0] m_axis_tdata_nb, m_axis_tdata_hb, m_axis_tdata_fb;
  wire m_axis_tlast_nb, m_axis_tlast_hb, m_axis_tlast_fb;
  wire [(C_M_AXIS_TDATA_WIDTH/8)-1:0] m_axis_tstrb_nb, m_axis_tstrb_hb, m_axis_tstrb_fb;


  reg[30*8:0] state = "setup";
  integer i;
  genvar g;

  reg axis_aresetn;
  //generate clocks
  reg axis_aclk;
  always begin
    axis_aclk = 0;
    forever #5 axis_aclk = ~axis_aclk; //100MHz
  end

  initial begin
    $dumpfile("sim.vcd");
    $dumpvars(0,tb);
  end

  AXIS_Split_v1_0#(
    .BUFFER_MODE("NONE"),
    .ENABLE_TSTRB(1),
    .ENABLE_TLAST(1),
    .MSH_FIRST(0)
  )uut_nb(
    .axis_aclk(axis_aclk),
    .axis_aresetn(axis_aresetn),
    .s_axis_tready(s_axis_tready_nb),
    .s_axis_tvalid(s_axis_tvalid_nb),
    .s_axis_tdata(s_axis_tdata_nb),
    .s_axis_tlast(s_axis_tlast_nb),
    .s_axis_tstrb(s_axis_tstrb_nb),
    .m_axis_tready(m_axis_tready_nb),
    .m_axis_tvalid(m_axis_tvalid_nb),
    .m_axis_tdata(m_axis_tdata_nb),
    .m_axis_tlast(m_axis_tlast_nb),
    .m_axis_tstrb(m_axis_tstrb_nb)
  );

  AXIS_Split_v1_0#(
    .BUFFER_MODE("HALF"),
    .ENABLE_TSTRB(1),
    .ENABLE_TLAST(1),
    .MSH_FIRST(0)
  )uut_hb(
    .axis_aclk(axis_aclk),
    .axis_aresetn(axis_aresetn),
    .s_axis_tready(s_axis_tready_hb),
    .s_axis_tvalid(s_axis_tvalid_hb),
    .s_axis_tdata(s_axis_tdata_hb),
    .s_axis_tlast(s_axis_tlast_hb),
    .s_axis_tstrb(s_axis_tstrb_hb),
    .m_axis_tready(m_axis_tready_hb),
    .m_axis_tvalid(m_axis_tvalid_hb),
    .m_axis_tdata(m_axis_tdata_hb),
    .m_axis_tlast(m_axis_tlast_hb),
    .m_axis_tstrb(m_axis_tstrb_hb)
  );

  AXIS_Split_v1_0#(
    .BUFFER_MODE("FULL"),
    .ENABLE_TSTRB(1),
    .ENABLE_TLAST(1),
    .MSH_FIRST(0)
  )uut_fb(
    .axis_aclk(axis_aclk),
    .axis_aresetn(axis_aresetn),
    .s_axis_tready(s_axis_tready_fb),
    .s_axis_tvalid(s_axis_tvalid_fb),
    .s_axis_tdata(s_axis_tdata_fb),
    .s_axis_tlast(s_axis_tlast_fb),
    .s_axis_tstrb(s_axis_tstrb_fb),
    .m_axis_tready(m_axis_tready_fb),
    .m_axis_tvalid(m_axis_tvalid_fb),
    .m_axis_tdata(m_axis_tdata_fb),
    .m_axis_tlast(m_axis_tlast_fb),
    .m_axis_tstrb(m_axis_tstrb_fb)
  );

  initial begin
    axis_aresetn = 1;
    #2
    axis_aresetn = 0;
    #10
    axis_aresetn = 1;
    @(posedge axis_aclk); #1;
    state = "No Buffer Cont. test";
    for(i = 0; i < 5; i=i+1) begin
      s_axis_tdata_nb = $random;
      s_axis_tlast_nb = $random;
      s_axis_tstrb_nb = $random;
      s_axis_tvalid_nb = 1;
      while (s_axis_tready_nb == 0) begin
        @(posedge axis_aclk); #1;
      end
      @(posedge axis_aclk); #1;
      s_axis_tvalid_nb = 0;
    end
    repeat(2) @(posedge axis_aclk); #1;
    state = "No Buffer Single test";
    for(i = 0; i < 5; i=i+1) begin
      s_axis_tdata_nb = $random;
      s_axis_tlast_nb = $random;
      s_axis_tstrb_nb = $random;
      s_axis_tvalid_nb = 1;
      while (s_axis_tready_nb == 0) begin
        @(posedge axis_aclk); #1;
      end
      @(posedge axis_aclk); #1;
      s_axis_tvalid_nb = 0;
      @(posedge axis_aclk); #1;
    end
    repeat(2) @(posedge axis_aclk); #1;
    state = "Half Buffer Cont. test";
    for(i = 0; i < 5; i=i+1) begin
      s_axis_tdata_hb = $random;
      s_axis_tlast_hb = $random;
      s_axis_tstrb_hb = $random;
      s_axis_tvalid_hb = 1;
      while (s_axis_tready_hb == 0) begin
        @(posedge axis_aclk); #1;
      end
      @(posedge axis_aclk); #1;
      s_axis_tvalid_hb = 0;
    end
    repeat(2) @(posedge axis_aclk); #1;
    state = "Half Buffer Single test";
    for(i = 0; i < 5; i=i+1) begin
      s_axis_tdata_hb = $random;
      s_axis_tlast_hb = $random;
      s_axis_tstrb_hb = $random;
      s_axis_tvalid_hb = 1;
      while (s_axis_tready_hb == 0) begin
        @(posedge axis_aclk); #1;
      end
      @(posedge axis_aclk); #1;
      s_axis_tvalid_hb = 0;
      @(posedge axis_aclk); #1;
    end
    repeat(2) @(posedge axis_aclk); #1;
    state = "Full Buffer Cont. test";
    for(i = 0; i < 5; i=i+1) begin
      s_axis_tdata_fb = $random;
      s_axis_tlast_fb = $random;
      s_axis_tstrb_fb = $random;
      s_axis_tvalid_fb = 1;
      while (s_axis_tready_fb == 0) begin
        @(posedge axis_aclk); #1;
      end
      @(posedge axis_aclk); #1;
      s_axis_tvalid_fb = 0;
    end
    repeat(2) @(posedge axis_aclk); #1;
    state = "Full Buffer Single test";
    for(i = 0; i < 5; i=i+1) begin
      s_axis_tdata_fb = $random;
      s_axis_tlast_fb = $random;
      s_axis_tstrb_fb = $random;
      s_axis_tvalid_fb = 1;
      while (s_axis_tready_fb == 0) begin
        @(posedge axis_aclk); #1;
      end
      @(posedge axis_aclk); #1;
      s_axis_tvalid_fb = 0;
      repeat (3) @(posedge axis_aclk); #1;
    end
    repeat(2) @(posedge axis_aclk); #1;
    state = "Finish";
    repeat(4) @(posedge axis_aclk); #1;
    $finish;
  end
endmodule

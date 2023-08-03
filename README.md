# AXI-Stream Splitter

## Contents of Readme

1. About
2. IP
   1. Basic Information on IP
   2. Interface Description
   3. Utilization
3. Simulation
4. Status Information
5. Licence

[![Repo on GitLab](https://img.shields.io/badge/repo-GitLab-6C488A.svg)](https://gitlab.com/suoglu/axis-split)
[![Repo on GitHub](https://img.shields.io/badge/repo-GitHub-3D76C2.svg)](https://github.com/suoglu/AXIS-Split)

---

## About

Splits one AXI-Stream transmission to two.

## IP

### Basic Information on IP

This IP includes options to enable/disable tlast and tstrb signals, choose which half is send first and a buffering mode. These options can be chosen via Vivado GUI.

Three buffering modes provided. Default mode is without any buffers (`"NONE"`). This mode uses directly the slave interface signals. Second mode is half (`"HALF"`) buffered mode. In this mode last half of the transmission is buffered. Last mode is the fully (`"FULL"`) buffered mode. This mode stores all transmission values into buffers. None of the modes add extra latency, assuming the next stage is always ready. Otherwise, it waits for the next stage.

AXI-Stream slave handshake happens on different times according to buffering mode. In fully buffered mode; slave handshake happens as soon as slave interface is valid, as we update the buffers. In this state, slave input values used for master output thus the buffers are not used. Ready signal is set when the buffers is not used and/or there is no ongoing transmission. In other buffering modes, slave handshake happens at the same as the second master handshake. Ready is not set during other times.

### Interface Description

|   Port   | Type | Width* |  Description |
| :------: | :----: | :----: |  ------  |
| `axis_aclk` | I | 1 | Common AXIS Clock |
| `axis_aresetn` | I | 1 | Common AXIS Reset |
| `s_axis_` | B | `C_S_AXIS_TDATA_WIDTH` | AXI-Stream Slave Input |
| `m_axis_` | B | `C_S_AXIS_TDATA_WIDTH`/2 | AXI-Stream Master Output |

I: Input  O: Output B: Bus

*Width of buses are for data channel.

### Utilization on Artix 7

- Format: no optional port/tlast enabled/tstrb enabled/both enabled or single value for all
- Slave data width is set to 32, MSH first.
- AXI4-Stream Data Width Converter is given for comparison. It is set up without any optional ports and with same data widths.

**No buffer:**

- LUT as Logic: 11
- Register as Flip Flop: 1

**Buffer second half:**

- LUT as Logic: 13
- Register as Flip Flop: 17/18/19/20

**Fully buffered:**

- LUT as Logic: 21/22/22/23
- Register as Flip Flop: 34/35/38/39

**AXI4-Stream Data Width Converter:**

- LUT as Logic: 15
- Register as Flip Flop: 53

## Simulation

Two cases for each buffer mode tested. First case continuously transmitting stream, while second case tests single transmissions. All optional ports are enabled, and all data generated randomly. In all cases, slave interface transmissions assumed to be full comply with AXI-Stream protocol.

## Status Information

**Last Simulation:** 10 May 2022, with [Icarus Verilog](http://iverilog.icarus.com).

## Licence

CERN Open Hardware Licence Version 2 - Weakly Reciprocal

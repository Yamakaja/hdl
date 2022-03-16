// ***************************************************************************
// ***************************************************************************
// Copyright 2022 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/1ps

module axi_tdd_ng #(

  // Timing register width, determines how long a single frame can be.
  // T_max = (2^REGISTER_WIDTH) / f_clk
  parameter         REGISTER_WIDTH = 32,

  parameter         CHANNEL_COUNT = 8,
  parameter         WINDOW_COUNT = 2,

  // Synchronization / triggering options. These are not mutually exclusive, and
  // both internal and external triggering can be available and selected at
  // runtime.
  parameter         SYNC_EXTERNAL = 0,
  parameter         SYNC_INTERNAL = 1,
  // Whether to insert a CDC stage with false path constraint for the external
  // synchronization input.
  parameter         SYNC_EXTERNAL_CDC = 0,
  parameter         SYNC_INTERNAL_COUNTER_WIDTH = 64,

  // Burst count register width. Determines the maximum amount of repetitions
  // of a frame.
  parameter         BURST_COUNT_WIDTH = 16
) (

  input           clk,
  input           resetn,

  output          tdd_armed,
  output          tdd_running,

  output          tdd_channel_0,
  output          tdd_channel_1,
  output          tdd_channel_2,
  output          tdd_channel_3,
  output          tdd_channel_4,
  output          tdd_channel_5,
  output          tdd_channel_6,
  output          tdd_channel_7,
  output          tdd_channel_8,
  output          tdd_channel_9,
  output          tdd_channel_10,
  output          tdd_channel_11,
  output          tdd_channel_12,
  output          tdd_channel_13,
  output          tdd_channel_14,
  output          tdd_channel_15,
  output          tdd_channel_16,
  output          tdd_channel_17,
  output          tdd_channel_18,
  output          tdd_channel_19,
  output          tdd_channel_20,
  output          tdd_channel_21,
  output          tdd_channel_22,
  output          tdd_channel_23,
  output          tdd_channel_24,
  output          tdd_channel_25,
  output          tdd_channel_26,
  output          tdd_channel_27,
  output          tdd_channel_28,
  output          tdd_channel_29,
  output          tdd_channel_30,
  output          tdd_channel_31,

  // sync signal
  input           sync_in,
  output          sync_out,

  // AXI BUS
  input           s_axi_aresetn,
  input           s_axi_aclk,
  input           s_axi_awvalid,
  input   [15:0]  s_axi_awaddr,
  output          s_axi_awready,
  input           s_axi_wvalid,
  input   [31:0]  s_axi_wdata,
  input   [ 3:0]  s_axi_wstrb,
  output          s_axi_wready,
  output          s_axi_bvalid,
  output  [ 1:0]  s_axi_bresp,
  input           s_axi_bready,
  input           s_axi_arvalid,
  input   [15:0]  s_axi_araddr,
  output          s_axi_arready,
  output          s_axi_rvalid,
  output  [ 1:0]  s_axi_rresp,
  output  [31:0]  s_axi_rdata,
  input           s_axi_rready
  );

  // Internal up bus, translated by up_axi
  wire              up_rstn;
  wire              up_clk;
  wire              up_wreq;
  wire    [13:0]    up_waddr;
  wire    [31:0]    up_wdata;
  wire              up_wack;
  wire              up_rreq;
  wire    [13:0]    up_raddr;
  wire    [31:0]    up_rdata;
  wire              up_rack;

  assign up_clk  = s_axi_aclk;
  assign up_rstn = s_axi_aresetn;

  // Config wires
  wire    [(CHANNEL_COUNT*WINDOW_COUNT)-1:0] tdd_channels_en;
  wire    [CHANNEL_COUNT-1:0]   tdd_channels_invert;
  wire    [(REGISTER_WIDTH*2*WINDOW_COUNT*CHANNEL_COUNT)-1:0] tdd_channels_cfg;
  wire    [REGISTER_WIDTH-1:0]  tdd_startup_delay;

  wire              tdd_enable;

  //   Synchronization config

  //     Sources:
  //      0b01: External trigger
  //      0b10: Internal counter
  wire    [1:0]     tdd_sync_sources;
  wire    [SYNC_INTERNAL_COUNTER_WIDTH-1:0] tdd_sync_period;
  wire              tdd_sync_software;

  wire    [CHANNEL_COUNT-1:0]   tdd_channels;

  assign {tdd_channel_31, tdd_channel_30, tdd_channel_29, tdd_channel_28,
    tdd_channel_27, tdd_channel_26, tdd_channel_25, tdd_channel_24,
    tdd_channel_23, tdd_channel_22, tdd_channel_21, tdd_channel_20,
    tdd_channel_19, tdd_channel_18, tdd_channel_17, tdd_channel_16,
    tdd_channel_15, tdd_channel_14, tdd_channel_13, tdd_channel_12,
    tdd_channel_11, tdd_channel_10, tdd_channel_9, tdd_channel_8,
    tdd_channel_7, tdd_channel_6, tdd_channel_5, tdd_channel_4,
    tdd_channel_3, tdd_channel_2, tdd_channel_1, tdd_channel_0} = tdd_channels;


  wire  [REGISTER_WIDTH-1:0]  tdd_counter;
  // Asserted to indicate the end of a tdd frame. This allows the channels to
  // reset outputs which are still open due to a potential missconfiguration.
  wire                        tdd_restart;
  wire                        tdd_sync;


  axi_tdd_ng_regmap #(
    .REGISTER_WIDTH (REGISTER_WIDTH),
    .CHANNEL_COUNT  (CHANNEL_COUNT),
    .WINDOW_COUNT   (WINDOW_COUNT),
    .SYNC_EXTERNAL  (SYNC_EXTERNAL),
    .SYNC_INTERNAL  (SYNC_INTERNAL),
    .SYNC_EXTERNAL_CDC  (SYNC_EXTERNAL_CDC),
    .SYNC_INTERNAL_COUNTER_WIDTH  (SYNC_INTERNAL_COUNTER_WIDTH),
    .BURST_COUNT_WIDTH  (BURST_COUNT_WIDTH)
  ) i_regmap (
    .up_rstn              (up_rstn),
    .up_clk               (up_clk),

    .up_wreq              (up_wreq),
    .up_waddr             (up_waddr),
    .up_wdata             (up_wdata),
    .up_wack              (up_wack),
    .up_rreq              (up_rreq),
    .up_raddr             (up_raddr),
    .up_rdata             (up_rdata),
    .up_rack              (up_rack)

    .tdd_clk              (clk),
    .tdd_resetn           (resetn),

    .tdd_enable           (tdd_enable),

    .tdd_channels_en      (tdd_channels_en),
    .tdd_channels_invert  (tdd_channels_invert),
    .tdd_channels_cfg     (tdd_channels_cfg),

    .tdd_burst_count      (tdd_burst_count),
    .tdd_startup_delay    (tdd_startup_delay),

    .tdd_sync_sources     (tdd_sync_sources),
    .tdd_sync_period      (tdd_sync_period),
    .tdd_sync_software    (tdd_sync_software)
  );

  axi_tdd_ng_counter #(
    .REGISTER_WIDTH (REGISTER_WIDTH),
    .BURST_COUNT_WDITH (BURST_COUNT_WIDTH)
  ) i_counter (
    .clk            (clk),
    .resetn         (resetn),

    .enable         (tdd_enable),

    .burst_count    (tdd_burst_count),
    .startup_delay  (tdd_startup_delay),

    .sync           (sync_out),

    .counter        (tdd_counter),
    .restart        (tdd_restart),
    .running        (tdd_running),
    .armed          (tdd_armed)

  );

  axi_tdd_ng_sync_gen #(
    .SYNC_EXTERNAL (SYNC_EXTERNAL),
    .SYNC_INTERNAL (SYNC_INTERNAL),
    .SYNC_INTERNAL_COUNTER_WIDTH (SYNC_INTERNAL_COUNTER_WIDTH)
  ) i_sync_gen (
    .clk          (clk),
    .resetn       (resetn),

    .sync_software (tdd_sync_software),
    .sync_in      (sync_in),
    .sync_out     (sync_out),
    .sync_sources (tdd_sync_sources),
    .sync_period  (tdd_sync_period)
  );

  genvar i;
  generate
    for (i = 0; i < CHANNEL_COUNT; i=i+1) begin
      axi_tdd_ng_channel #(
        .REGISTER_WIDTH (REGISTER_WIDTH),
        .WINDOW_COUNT   (WINDOW_COUNT)
      ) i_channel (
        .clk        (clk),
        .resetn     (resetn),

        .en         (tdd_channels_en[i*WINDOW_COUNT +: WINDOW_COUNT]),
        .invert     (tdd_channels_invert[i]),
        .cfg        (tdd_channels_cfg[i*WINDOW_COUNT*REGISTER_WIDTH +: WINDOW_COUNT*REGISTER_WIDTH]),

        .counter    (tdd_counter),
        .restart    (tdd_restart),

        .out        (tdd_channels[i])
        );
    end
  endgenerate

  up_axi #(
    .AXI_ADDRESS_WIDTH(16))
  i_up_axi (
    .up_rstn(s_axi_aresetn),
    .up_clk(s_axi_aclk),

    .up_axi_awvalid(s_axi_awvalid),
    .up_axi_awaddr(s_axi_awaddr),
    .up_axi_awready(s_axi_awready),
    .up_axi_wvalid(s_axi_wvalid),
    .up_axi_wdata(s_axi_wdata),
    .up_axi_wstrb(s_axi_wstrb),
    .up_axi_wready(s_axi_wready),
    .up_axi_bvalid(s_axi_bvalid),
    .up_axi_bresp(s_axi_bresp),
    .up_axi_bready(s_axi_bready),
    .up_axi_arvalid(s_axi_arvalid),
    .up_axi_araddr(s_axi_araddr),
    .up_axi_arready(s_axi_arready),
    .up_axi_rvalid(s_axi_rvalid),
    .up_axi_rresp(s_axi_rresp),
    .up_axi_rdata(s_axi_rdata),
    .up_axi_rready(s_axi_rready),

    .up_wreq(up_wreq),
    .up_waddr(up_waddr),
    .up_wdata(up_wdata),
    .up_wack(up_wack),
    .up_rreq(up_rreq),
    .up_raddr(up_raddr),
    .up_rdata(up_rdata),
    .up_rack(up_rack)
  );

endmodule

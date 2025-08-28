/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_pwm_block (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  assign uio_oe = 8'b10001111; // set data directions
  assign uio_out[6:0] = 7'b000_0000; // all unused outputs are assigned
  assign uo_out[7:3] = 5'b00000;

  spi_pwm top_mod(.reset_n(rst_n), .cpol(1'b0), .cpha(1'b0), .sclk(uio_in[4]), .ss_n(uio_in[5]), .mosi(uio_in[6]),
   .miso(uio_out[7]), .rx_enable(1'b1), .tx(32'd0), .rx(), .busy(), .pwm_clk(clk), .pwm_out(uo_out[2:0]));

  // List all unused inputs to prevent warnings
  wire _unused = &{ena, ui_in, uio_in[3:0], uio_in[7], 1'b0};

endmodule

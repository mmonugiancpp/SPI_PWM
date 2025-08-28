// -----------------------------------------------------------------------------
// Company:
// Engineer:
//
// Create Date: 08/28/2025 10:42:54 AM
// Design Name:
// Module Name: spi_pwm - Behavioral (Verilog translation, clocked registers)
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//   SPI slave interface to configure a 3-channel PWM.
//   Receives 32-bit commands via SPI, decoded into:
//     - Enable (bits[0] when header == 2'b00)
//     - Duty cycle (24 bits when header == 2'b01)
//     - Frequency (30 bits when header == 2'b10, left-padded to 32 bits)
//
// Dependencies:
//   - spi_slave (with parameter data_length=32)
//   - PWM (translated earlier)
//
// Revision:
//   0.02 - Registers made synchronous to pwm_clk
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
module spi_pwm (
    input  wire        reset_n,     // Asynchronous active low reset
    input  wire        cpol,        // Clock polarity mode
    input  wire        cpha,        // Clock phase mode
    input  wire        sclk,        // SPI clock
    input  wire        ss_n,        // Slave select
    input  wire        mosi,        // Master out, slave in
    output wire        miso,        // Master in, slave out
    input  wire        rx_enable,   // Enable to expose RX buffer
    input  wire [31:0] tx,          // Data to transmit
    output wire [31:0] rx,          // Data received
    output wire        busy,        // Slave busy signal
    input  wire        pwm_clk,     // PWM clock
    output wire [2:0]  pwm_out      // PWM outputs
);

    // RX buffer (updated by SPI slave)
    reg [31:0] rx_buffer = 32'd0;

    // PWM registers (latched from rx_buffer)
    reg        pwm_enable = 1'b0;
    reg [23:0] duty_cycle = 24'd0;
    reg [31:0] frequency  = 32'd0;

    assign rx = rx_buffer;

    // -------------------------------------------------------------------------
    // Register decode logic (synchronous to pwm_clk)
    // -------------------------------------------------------------------------
    always @(posedge pwm_clk or negedge reset_n) begin
        if (!reset_n) begin
            pwm_enable <= 1'b0;
            duty_cycle <= 24'd0;
            frequency  <= 32'd0;
        end else begin
            case (rx_buffer[31:30])
                2'b00: pwm_enable <= rx_buffer[0];
                2'b01: duty_cycle <= rx_buffer[23:0];
                2'b10: frequency  <= {2'b00, rx_buffer[29:0]};
                default: begin
                    // Hold previous values
                end
            endcase
        end
    end

    // -------------------------------------------------------------------------
    // SPI slave instance
    // -------------------------------------------------------------------------
    spi_slave #(
        .data_length(32)
    ) u_spi_slave (
        .reset_n   (reset_n),
        .cpol      (cpol),
        .cpha      (cpha),
        .sclk      (sclk),
        .ss_n      (ss_n),
        .mosi      (mosi),
        .miso      (miso),
        .rx_enable (rx_enable),
        .tx        (tx),
        .rx        (rx_buffer),
        .busy      (busy)
    );

    // -------------------------------------------------------------------------
    // PWM instance
    // -------------------------------------------------------------------------
    PWM u_pwm (
        .duty_cycle (duty_cycle),
        .frequency  (frequency),
        .clk        (pwm_clk),
        .reset_n    (reset_n),
        .enable     (pwm_enable),
        .pwm_out    (pwm_out)
    );

endmodule
 

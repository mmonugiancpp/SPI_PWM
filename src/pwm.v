// -----------------------------------------------------------------------------
// Company:
// Engineer:
//
// Create Date: 03/28/2025 02:54:02 PM
// Design Name:
// Module Name: pwm - Behavioral (Verilog translation)
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//   3-channel PWM with per-channel 8-bit counters. Each channel compares its
//   counter against one 4-bit nibble from duty_cycle:
//     - pwm_out[0] uses duty_cycle[23:20]
//     - pwm_out[1] uses duty_cycle[15:12]
//     - pwm_out[2] uses duty_cycle[7:4]
//   A shared per-channel prescaler advances the counter when
//   prescaler >= frequency.
//
// Dependencies:
//
// Revision:
//   0.01 - File Created (translated from VHDL)
// Additional Comments:
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
module PWM (
    input  wire [23:0] duty_cycle,
    input  wire [31:0] frequency,
    input  wire        clk,
    input  wire        reset_n,   // active-low asynchronous reset
    input  wire        enable,
    output reg  [2:0]  pwm_out
);

    // Counters are 8-bit (0..255). Prescalers match 'frequency' width.
    reg [7:0]  counter0 = 8'd0;
    reg [7:0]  counter1 = 8'd0;
    reg [7:0]  counter2 = 8'd0;

    reg [31:0] prescaler0 = 32'd0;
    reg [31:0] prescaler1 = 32'd0;
    reg [31:0] prescaler2 = 32'd0;

    localparam [7:0] COUNTER_VALUE = 8'd255;

    // RED channel (pwm_out[0]) uses duty_cycle[23:20]
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pwm_out[0] <= 1'b0;
            counter0   <= 8'd0;
            prescaler0 <= 32'd0;
        end else begin
            if (enable) begin
                if (prescaler0 >= frequency) begin
                    prescaler0 <= 32'd0;
                    if (counter0 >= COUNTER_VALUE)
                        counter0 <= 8'd0;
                    else
                        counter0 <= counter0 + 8'd1;
                end else begin
                    prescaler0 <= prescaler0 + 32'd1;
                end

                if (counter0 < {4'd0, duty_cycle[23:20]})
                    pwm_out[0] <= 1'b1;
                else
                    pwm_out[0] <= 1'b0;
            end else begin
                prescaler0 <= 32'd0;
                counter0   <= 8'd0;
                pwm_out[0] <= 1'b0;
            end
        end
    end

    // GREEN channel (pwm_out[1]) uses duty_cycle[15:12]
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pwm_out[1] <= 1'b0;
            counter1   <= 8'd0;
            prescaler1 <= 32'd0;
        end else begin
            if (enable) begin
                if (prescaler1 >= frequency) begin
                    prescaler1 <= 32'd0;
                    if (counter1 >= COUNTER_VALUE)
                        counter1 <= 8'd0;
                    else
                        counter1 <= counter1 + 8'd1;
                end else begin
                    prescaler1 <= prescaler1 + 32'd1;
                end

                if (counter1 < {4'd0, duty_cycle[15:12]})
                    pwm_out[1] <= 1'b1;
                else
                    pwm_out[1] <= 1'b0;
            end else begin
                prescaler1 <= 32'd0;
                counter1   <= 8'd0;
                pwm_out[1] <= 1'b0;
            end
        end
    end

    // BLUE channel (pwm_out[2]) uses duty_cycle[7:4]
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            pwm_out[2] <= 1'b0;
            counter2   <= 8'd0;
            prescaler2 <= 32'd0;
        end else begin
            if (enable) begin
                if (prescaler2 >= frequency) begin
                    prescaler2 <= 32'd0;
                    if (counter2 >= COUNTER_VALUE)
                        counter2 <= 8'd0;
                    else
                        counter2 <= counter2 + 8'd1;
                end else begin
                    prescaler2 <= prescaler2 + 32'd1;
                end

                if (counter2 < {4'd0, duty_cycle[7:4]})
                    pwm_out[2] <= 1'b1;
                else
                    pwm_out[2] <= 1'b0;
            end else begin
                prescaler2 <= 32'd0;
                counter2   <= 8'd0;
                pwm_out[2] <= 1'b0;
            end
        end
    end

endmodule
 

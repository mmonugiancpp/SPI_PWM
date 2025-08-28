// -----------------------------------------------------------------------------
// Company: HES-SO AGSL
// Engineer: https://github.com/nematoli/SPI-FPGA-VHDL (translated to Verilog)
// with edits from John Biselx
//
// Create Date: 08/28/2025 10:03:43 AM
// Design Name:
// Module Name: spi_slave - Behavioral (Verilog translation)
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//   SPI slave, parameterizable data width.
//   - Supports CPOL, CPHA
//   - One-hot bit counter
//   - Shifts MOSI into rxBuffer
//   - Shifts txBuffer out on MISO
//   - Tri-states MISO when not selected
//
// Revision:
//   0.01 - File Created
// -----------------------------------------------------------------------------

`timescale 1ns/1ps
module spi_slave #(
    parameter integer data_length = 16  // Data length in bits
) (
    input  wire                  reset_n,   // Asynchronous active low reset
    input  wire                  cpol,      // Clock polarity mode
    input  wire                  cpha,      // Clock phase mode
    input  wire                  sclk,      // SPI clock
    input  wire                  ss_n,      // Slave select
    input  wire                  mosi,      // Master out, slave in
    output wire                  miso,      // Master in, slave out
    input  wire                  rx_enable, // Enable to expose rxBuffer
    input  wire [data_length-1:0] tx,       // Data to transmit
    output reg  [data_length-1:0] rx,       // Data received
    output wire                  busy       // Slave busy
);

    // Internal signals
    wire mode;
    reg  clk;
    reg  [data_length:0] bit_counter;  // one-hot shift register
    reg  [data_length-1:0] rxBuffer;
    reg  [data_length-1:0] txBuffer;
    reg miso_data;
    reg miso_enable;
    assign miso = miso_enable ? miso_data : 1'bZ;

    assign busy = ~ss_n;
    assign mode = cpol ^ cpha;

    // Internal clock generation
    always @(*) begin
        if (ss_n)
            clk = 1'b0;
        else
            clk = (mode) ? sclk : ~sclk;
    end

    // Bit counter logic (one-hot shift)
    always @(posedge clk or posedge ss_n or negedge reset_n) begin
        if (!reset_n || ss_n) begin
            bit_counter <= { {(data_length){1'b0}}, ~cpha };  // init position
        end else begin
            bit_counter <= { bit_counter[data_length-1:0], 1'b0 };
        end
    end

    // Receive and transmit logic
    always @(posedge clk or negedge reset_n or posedge ss_n) begin
        if (!reset_n) begin
            rxBuffer <= {data_length{1'b0}};
            rx       <= {data_length{1'b0}};
            txBuffer <= {data_length{1'b0}};
            miso_enable     <= 1'b0;
            miso_data <= 1'b0;
        end else if (ss_n) begin
            // Latch outputs when SS released
            if (rx_enable)
                rx <= rxBuffer;
            txBuffer <= tx;
            miso_enable     <= 1'b0;
            miso_data <= 1'b0;
        end else begin
            // --- Receive ---
            if (!cpha) begin
                if (bit_counter != {{(data_length-1){1'b0}}, 1'b1}) begin
                    if (!sclk)  // falling edge of true SPI clock
                        rxBuffer <= {rxBuffer[data_length-2:0], mosi};
                end
            end else begin
                if (bit_counter != { {(data_length){1'b0}}, 1'b1}) begin
                    if (!sclk)
                        rxBuffer <= {rxBuffer[data_length-2:0], mosi};
                end
            end

            // --- Transmit shift register ---
            if (bit_counter[data_length] == 1'b0) begin
                txBuffer <= {txBuffer[data_length-2:0], txBuffer[data_length-1]};
            end

            // --- Drive MISO ---
            miso_enable     <= 1'b1;
            miso_data <= txBuffer[data_length-1];
        end
    end

endmodule
 

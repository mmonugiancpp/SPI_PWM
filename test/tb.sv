`default_nettype none
`timescale 1ns / 1ps

/* This testbench just instantiates the module and makes some convenient wires
   that can be driven / tested by the cocotb test.py.
*/
module tb ();

  // Dump the signals to a VCD file. You can view it with gtkwave or surfer.
  initial begin
    $dumpfile("tb.vcd");
    $dumpvars(0, tb);
    #1;
  end

  parameter SPI_MODE = 0; // CPOL = 0, CPHA = 1
  parameter SPI_CLK_DELAY = 20;  // 2.5 MHz
  parameter MAIN_CLK_DELAY = 2;  // 25 MHz

  logic w_CPOL; // clock polarity
  logic w_CPHA; // clock phase

  assign w_CPOL = (SPI_MODE == 2) | (SPI_MODE == 3);
  assign w_CPHA = (SPI_MODE == 1) | (SPI_MODE == 3);

  // Wire up the inputs and outputs:
  reg clk;
  reg rst_n;
  reg ena;
  reg [7:0] ui_in;
  reg [7:0] uio_in;
  logic w_SPI_Clk;
  logic r_SPI_En    = 1'b0;
  logic w_SPI_CS_n;
  logic w_SPI_MOSI;
  logic w_SPI_MISO;
  
  wire [7:0] uo_out;
  wire [7:0] uio_out;
  wire [7:0] uio_oe;


  // Master Specific
  logic [7:0] r_Master_TX_Byte = 0;
  logic r_Master_TX_DV = 1'b0;
  logic r_Master_CS_n = 1'b1;
  logic w_Master_TX_Ready;
  logic r_Master_RX_DV;
  logic [7:0] r_Master_RX_Byte;
  assign uio_in[7:6] = {r_Master_CS_n, w_SPI_MOSI};
  assign uio_in[4] = w_SPI_Clk;
  assign w_SPI_MISO = uio_out[5];

  // Replace tt_um_example with your module name:
  tt_um_pwm_block user_project (
      .ui_in  (ui_in),    // Dedicated inputs
      .uo_out (uo_out),   // Dedicated outputs
      .uio_in (uio_in),   // IOs: Input path
      .uio_out(uio_out),  // IOs: Output path
      .uio_oe (uio_oe),   // IOs: Enable path (active high: 0=input, 1=output)
      .ena    (ena),      // enable - goes high when design is selected
      .clk    (clk),      // clock
      .rst_n  (rst_n)     // not reset
  );

  

  SPI_Master 
    #(.SPI_MODE(SPI_MODE),
    .CLKS_PER_HALF_BIT(2),
    .NUM_SLAVES(1)) SPI_Master_UUT
    (
      // Control/Data Signals,
      .i_Rst_L(rst_n),     // FPGA Reset
      .i_Clk(clk),         // FPGA Clock

      // TX (MOSI) Signals
      .i_TX_Byte(r_Master_TX_Byte),     // Byte to transmit on MOSI
      .i_TX_DV(r_Master_TX_DV),         // Data Valid Pulse with i_TX_Byte
      .o_TX_Ready(w_Master_TX_Ready),   // Transmit Ready for Byte

      // RX (MISO) Signals
      .o_RX_DV(r_Master_RX_DV),       // Data Valid pulse (1 clock cycle)
      .o_RX_Byte(r_Master_RX_Byte),   // Byte received on MISO

      // SPI Interface
      .o_SPI_Clk(w_SPI_Clk),
      .i_SPI_MISO(w_SPI_MISO),
      .o_SPI_MOSI(w_SPI_MOSI)
  );
endmodule

// Displays time on seven-segment displays, initialised to 00:00:00,
// tick rate controlled by SW[1:0]
//
// Ports :
// clk
// sig_in
// rise
//
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module rising_edge_detector (
    input  logic clk,
    input  logic sig_in,
    output logic rise
);
  logic prev = '0;
  logic next;

  always_ff @(posedge clk) begin
    prev <= next;
  end

  assign next = sig_in;

  assign rise = (sig_in && !prev);
endmodule

// Synchronous set and clear flip-flop
// disarm takes priority
//
// Ports :
// clk
// arm
// disarm
// armed
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module arming_latch (
    input  logic clk,
    input  logic arm,
    input  logic disarm,
    output logic armed
);
  initial armed = '0;

  always_ff @(posedge clk or posedge disarm) begin
    if (disarm) armed <= '0;
    if (arm && !disarm) armed <= 1'(1);
  end

endmodule

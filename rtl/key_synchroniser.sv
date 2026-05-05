// Normal mode: count increments on each tick
// Edit mode: inc increments count / dec decrements count
//
// Parameters:
// N = 60
// WIDTH = 6
// Ports :
// clk
// tick
// edit_mode
// inc
// dec
// count
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module key_synchroniser (
    input logic clk,
    input logic [3:0] key_n, // active-low, asynchronous
    output logic [3:0] key_sync // active-high, synchronised
);

    logic [3:0] key_inv;
    logic [3:0] key_hold;

    // Initialise Flip-Flops
    initial begin
        key_hold = '0;
        key_sync = '0;
    end

    assign key_inv = ~key_n;

    always_ff @ (posedge clk) begin
        key_hold [3:0] <= key_inv [3:0];
        key_sync [3:0] <= key_hold [3:0];
    end

endmodule

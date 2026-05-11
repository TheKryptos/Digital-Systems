// edit_mode: inc/dec to manually set the timer countdown
// !editmode: runs as a countdown
//
// Parameters:
// HOLD_CYCLES = 50_000_000
//
// Ports :
// clk
// button
// pulse
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module editable_countdown #(
    parameter int MAX = 59,
    parameter int WIDTH = 6
) (
    input logic clk,
    input logic clr,
    input logic tick,
    input logic edit_mode,
    input logic inc,
    input logic dec,
    output logic [WIDTH-1:0] count,
    output logic borrow_out // ticks over when the counter wraps
);

// Instantiate up_down_counter
logic enable;
logic up;
up_down_counter_rst #(
    .MAX(MAX),
    .WIDTH(WIDTH)
) u_counter (
    .clk(clk),
    .rst(clr),
    .enable(enable),
    .up(up),
    .count(count)
);

wire inc_event = edit_mode && inc && !dec;
wire dec_event = edit_mode && dec && !inc;
wire tick_event = !edit_mode && tick;

assign enable = tick_event | inc_event | dec_event;
assign up = inc_event;
// borrow_out high only when counter reaches 0
assign borrow_out = (count == '0) && tick_event && !clr && !edit_mode;


endmodule

// --------------------------------------------------
// Stage 2- FSM (Start/Stop Control) Implementation
// --------------------------------------------------
`timescale 1ns / 1ps

module user_top_timer_s2 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // ------------------
  // Basic Timekeeping
  // ------------------

  logic tick;
  logic seconds_borrow;
  logic minutes_borrow;
  logic unused_borrow;

  // Minutes
  editable_countdown #(
      .MAX  (99),
      .WIDTH(7)
  ) u_minutes_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(minutes_borrow),
      .edit_mode(1'(0)),
      .inc(1'(0)),
      .dec(1'(0)),
      .count(hours_disp),
      .borrow_out(unused_borrow)
  );

  // Seconds
  editable_countdown #(
      .MAX  (59),
      .WIDTH(7)
  ) u_seconds_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(seconds_borrow),
      .edit_mode(1'(0)),
      .inc(1'(0)),
      .dec(1'(0)),
      .count(minutes_disp),
      .borrow_out(minutes_borrow)
  );

  // Centiseconds
  editable_countdown #(
      .MAX  (99),
      .WIDTH(7)
  ) u_centiseconds_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(tick),
      .edit_mode(1'(0)),
      .inc(1'(0)),
      .dec(1'(0)),
      .count(seconds_disp),
      .borrow_out(seconds_borrow)
  );

  // Instantiate restartable_rate_generator
  logic run;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)  // ticks once every second
  ) u_restartable_rate_generator (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  assign run = 1'b1;

  // ------------------------
  // FSM (Start/Stop Control)
  // ------------------------

  // Instantiate rising_edge detector
  rising

  // Driving outputs to 0
  assign led = '0;
  assign blank_hours = '0;
  assign blank_minutes = '0;
  assign blank_seconds = '0;



endmodule

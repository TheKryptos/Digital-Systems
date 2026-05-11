// --------------------------------------------------
// Stage 2- FSM (Control Logic and Mode Selection)
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
  // Driving unused outputs to 0
  assign led = '0;
  assign blank_hours = '0;
  assign blank_minutes = '0;
  assign blank_seconds = '0;

  // ------------------
  // Basic Timekeeping
  // ------------------

  logic tick;
  logic seconds_borrow;
  logic minutes_borrow;
  logic unused_borrow;
  logic clr;

  // Minutes
  logic minutes_inc;
  logic minutes_dec;
  logic minutes_edit;
  editable_countdown #(
      .MAX  (99),
      .WIDTH(7)
  ) u_minutes_countdown (
      .clk(clk),
      .clr(clr),
      .tick(minutes_borrow),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(hours_disp),
      .borrow_out(unused_borrow)
  );

  // Seconds
  logic seconds_inc;
  logic seconds_dec;
  logic seconds_edit;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(7)
  ) u_seconds_countdown (
      .clk(clk),
      .clr(clr),
      .tick(seconds_borrow),
      .edit_mode(seconds_mode),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(minutes_disp),
      .borrow_out(minutes_borrow)
  );

  // Centiseconds
  logic centiseconds_inc;
  logic centiseconds_dec;
  logic centiseconds_edit;
  editable_countdown #(
      .MAX  (99),
      .WIDTH(7)
  ) u_centiseconds_countdown (
      .clk(clk),
      .clr(clr),
      .tick(tick),
      .edit_mode(centiseconds_edit),
      .inc(centiseconds_inc),
      .dec(centiseconds_dec),
      .count(seconds_disp),
      .borrow_out(seconds_borrow)
  );

  // ------------------------
  // Start/Stop Control
  // ------------------------

  // button[0] controls start/stop //
  logic rise;
  rising_edge_detector u_rise_edge_b0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise)
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

assign run = rise && !mode_enable;


  // ------------------------
  // Mode Selection
  // ------------------------
  // button[3] controls set/mode //

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_edit_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  // Editing modes
  assign minutes_edit = (mode_enable == 3'b100);
  assign seconds_edit = (mode_enable == 3'b010);
  assign centiseconds_edit = (mode_enable == 3'b001);

  // ------------------------
  // Manual Adjustment (Setting Timer)
  // ------------------------
  // button[1] - manual increment
  logic inc_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5s hold
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10) // 10 Hz Repeat
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );

  // button[0] - manual decerement
  logic dec_pulse;
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5s hold
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10) // 10 Hz Repeat
  ) u_dec_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(dec_pulse)
  );

assign minutes_inc = minutes_edit && inc_pulse;
assign minutes_dec = minutes_edit && dec_pulse;
assign seconds_inc = seconds_edit && inc_pulse;
assign seconds_dec = seconds_edit && dec_pulse;
assign centiseconds_inc = centiseconds_edit && inc_pulse;
assign centiseconds_dec = centiseconds_edit && dec_pulse;



endmodule

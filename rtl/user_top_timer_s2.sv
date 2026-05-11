// --------------------------------------------------
// Stage 2- Start/Stop Control
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

  logic tick;
  logic seconds_borrow;
  logic minutes_borrow;
  logic unused_borrow;

  // Hours
  logic [4:0] hours;
  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(minutes_borrow),
      .edit_mode(1'(0)),
      .inc(1'(0)),
      .dec(1'(0)),
      .count(hours),
      .borrow_out(unused_borrow)
  );

  // Minutes
  logic [5:0] minutes;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(seconds_borrow),
      .edit_mode(1'(0)),
      .inc(1'(0)),
      .dec(1'(0)),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );

  // Seconds
  logic [5:0] seconds;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(tick),
      .edit_mode(1'(0)),
      .inc(1'(0)),
      .dec(1'(0)),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );

  // Zero-extend counter values to display outputs
  assign hours_disp   = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Instantiate restartable_rate_generator
  logic running = '0;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)  // ticks once every second
  ) u_restartable_rate_generator (
      .clk (clk),
      .run (running),
      .tick(tick)
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

  // Holds the run value when toggled
  always_ff @(posedge clk) begin
    if (rise) running <= !running; // Invert running when button[0] is pressed
  end

endmodule

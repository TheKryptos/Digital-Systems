// ---------------------------------
// Timer iddles at Zero
// ---------------------------------
`timescale 1ns / 1ps

module user_top_timer_s3 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
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
  /* verilator lint_off UNUSED */
  logic [2:0] mode_enable = 3'b000;
  /* verilator lint_on UNUSED */

  // Driving unused outputs to 0
  assign led = '0;
  assign blank_hours = '0;
  assign blank_minutes = '0;
  assign blank_seconds = '0;

  logic tick;
  logic seconds_borrow;
  logic minutes_borrow;

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
      /* verilator lint_off PINCONNECTEMPTY */
      .borrow_out()
      /* verilator lint_on PINCONNECTEMPTY */
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

  // Auto-Stop at Zero
  logic stop;
  assign stop = (seconds == 6'(0)) && (minutes == 6'(0)) && (hours == 5'(0));

  // Holds the run value when toggled
  always_ff @(posedge clk) begin
    if (rise) running <= !running;  // Invert running when button[0] is pressed
    if (stop) running <= '0;
  end


`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule

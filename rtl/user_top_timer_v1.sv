// ------------------------------------------------------------------

// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_timer_v1 #(
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

  // Instantiate button_auto_repeat
  button_auto_repeat #(
      .HOLD_CYCLES  (),
      .REPEAT_CYCLES()
  ) u_button_auto_repeat (
      .clk(clk),
      .button(),
      .pulse(),
  );

  // Instantiate edit_mode_selector
  edit_mode_selector #(
      .HOLD_CYCLES()
  ) u_edit_mode_selector (
      .clk(clk),
      .button(),
      .mode_enable()
  );

  // Instantiate editable_countdown
  editable_countdown #(
      .MAX  (),
      .WIDTH()
  ) u_editable_countdown (
      .clk(clk),
      .clr(),
      .tick(),
      .edit_mode(),
      .inc(),
      .dec(),
      .count(),
      .borrow_out()
  );

  // Instantiate pwm_generator
  pwm_generator #(
      .PERIOD_CYCLES(),
      .DUTY_CYCLES  ()
  ) u_pwm_generator (
      .clk(clk),
      .rst(),
      .pwm_out()
  );

  // Instantiate restartable_rate_generator
  restartable_rate_generator #(
      .CYCLE_COUNT()
  ) u_restartable_rate_generator (
      .clk (clk),
      .run (),
      .tick()
  );

  // Instantiate rising_edge_detector
  rising_edge_detector u_rising_edge (
      .clk(clk),
      .sig_in(),
      .rise()
  );


  /* FSM Design */

`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule

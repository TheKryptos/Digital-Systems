`timescale 1ns / 1ps

module user_top_watch_v4 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
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
  // Basic Time Display
  // ------------------

  // Seconds
  logic seconds_tick;
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_seconds (
      .clk(clk),
      .tick(seconds_tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds)
  );

  // Minutes
  logic minutes_tick;
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;

  editable_counter #(
      .N(60),
      .WIDTH(6)
  ) u_minutes (
      .clk(clk),
      .tick(minutes_tick),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes)
  );

  // Hours
  logic hours_tick;
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;

  editable_counter #(
      .N(24),
      .WIDTH(5)
  ) u_hours (
      .clk(clk),
      .tick(hours_tick),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours)
  );

  // Derive 1 Hz tick from system clock
  logic run;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)
  ) u_divider_1_Hz (
      .clk (clk),
      .run (run),
      .tick(seconds_tick)
  );

  // Run goes low when transition from mode 001 to 010
  assign run = ~(seconds_edit && button[3]);


  assign minutes_tick = seconds_tick && (seconds_disp == 7'(59));
  assign hours_tick = seconds_tick && (seconds_disp == 7'(59)) && minutes_tick && (minutes_disp == 7'(59));

  // Zero-extend counter values to display outputs
  assign hours_disp = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Unused
  assign led = 10'b0;

  // ------------------
  // Mode Selection
  // ------------------

  // Instantiate edit_mode_selector
  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)  // Holds longer than 1 second
  ) u_mode_selector (
      .clk(clk),
      .button(button[3]),
      .mode_enable(mode_enable)
  );

  // Instantiate pwm_generator
  logic pwm_out;
  pwm_generator #(
      .PERIOD_CYCLES(CYCLES_PER_SECOND / 2),  // Blinks at 2Hz
      .DUTY_CYCLES  (CYCLES_PER_SECOND / 10)  // 2/10: 80% DUTY_CYCLES on high
  ) u_pwm_generator (
      .clk(clk),
      .rst(1'(0)),
      .pwm_out(pwm_out)
  );

  // Editing modes
  assign seconds_edit = (mode_enable == 3'b001);
  assign minutes_edit = (mode_enable == 3'b010);
  assign hours_edit = (mode_enable == 3'b100);

  // Flash Seven-Segments for corresponding editing mode
  assign blank_hours = hours_edit && pwm_out;
  assign blank_minutes = minutes_edit && pwm_out;
  assign blank_seconds = seconds_edit && pwm_out;

  // ------------------
  // Edit Logic
  // ------------------

  /* Enter 10Hz mode when KEY[0] or KEY[1] > 0.5s */

  // Instantiate button_auto_repeat (2 Modes: Inc/Dec at 10Hz)
  logic inc_pulse;
  logic dec_pulse;

   button_auto_repeat #(
    .HOLD_CYCLES(CYCLES_PER_SECOND / 2), // 0.5s hold
    .REPEAT_CYCLES(CYCLES_PER_SECOND / 10) // 10 Hz repeat
   ) u_inc_repeat (
    .clk(clk),
    .button(button[1]),
    .pulse(inc_pulse)
  );

  button_auto_repeat #(
    .HOLD_CYCLES(CYCLES_PER_SECOND / 2), // 0.5s hold
    .REPEAT_CYCLES(CYCLES_PER_SECOND / 10) // 10 Hz repeat
  ) u_dec_repeat (
    .clk(clk),
    .button(button[0]),
    .pulse(dec_pulse)
  );

  // Increment/Decrement Logic
  assign seconds_inc = seconds_edit && inc_pulse;
  assign seconds_dec = seconds_edit && dec_pulse;
  assign minutes_inc = minutes_edit && inc_pulse;
  assign minutes_dec = minutes_edit && dec_pulse;
  assign hours_inc   = hours_edit && inc_pulse;
  assign hours_dec   = hours_edit && dec_pulse;

endmodule


// Displays time on seven-segment displays, initialised to 00:00:00,
// tick rate controlled by SW[1:0]
//
// Parameters:
//
//
// Ports :
//
//
//
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module top_time_display_v1 #(
    parameter int CYCLES_PER_SECOND = 50_000_000
) (
    input logic CLOCK_50,
    input logic [1:0] SW,
    output logic [6:0] HEX5,
    output logic [6:0] HEX4,
    output logic [6:0] HEX3,
    output logic [6:0] HEX2,
    output logic [6:0] HEX1,
    output logic [6:0] HEX0
);

  // Instantiation //

  // 3 restartable_rate_generator //
  localparam int CYCLECOUNT1HZ = CYCLES_PER_SECOND;
  localparam int CYCLECOUNT25HZ = CYCLES_PER_SECOND / 25;
  localparam int CYCLECOUNT1KHZ = CYCLES_PER_SECOND / 1000;

  logic tick_1Hz;
  logic tick_25Hz;
  logic tick_1kHz;
  logic run = 1'b1;

  // 1Hz  Tick Rate
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLECOUNT1HZ)
  ) tick_rate_1Hz (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1Hz)
  );

  // 25 Hz Tick Rate
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLECOUNT25HZ)
  ) tick_rate_ (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_25Hz)
  );

  // 1 kHz Tick Rate
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLECOUNT1KHZ)
  ) tick_rate_3 (
      .clk (CLOCK_50),
      .run (run),
      .tick(tick_1kHz)
  );

  logic selected_tick;

  always_comb begin
    case (SW)
      2'b00:   selected_tick = tick_1Hz;
      2'b01:   selected_tick = tick_25Hz;
      2'b10:   selected_tick = tick_1kHz;
      2'b11:   selected_tick = 1'b1;
      default: selected_tick = tick_1Hz;
    endcase
  end

  // 1 hms_counter
  logic [4:0] hours;
  logic [5:0] minutes;
  logic [5:0] seconds;
  hms_counter #(
      .N_HOURS  (24),
      .N_MINUTES(60),
      .N_SECONDS(60),

      .W_HOURS  (5),
      .W_MINUTES(6),
      .W_SECONDS(6)
  ) hms_count (
      .clk(CLOCK_50),
      .enable(selected_tick),
      .hours(hours),
      .minutes(minutes),
      .seconds(seconds)
  );

  // 3 binary_to_bcd
  logic [3:0] tens_hours;
  logic [3:0] ones_hours;
  logic [3:0] tens_minutes;
  logic [3:0] ones_minutes;
  logic [3:0] tens_seconds;
  logic [3:0] ones_seconds;

  binary_to_bcd bcd_hours (
      .bin ({2'b0, hours}),
      .tens(tens_hours),
      .ones(ones_hours)
  );

  binary_to_bcd bcd_minutes (
      .bin ({1'b0, minutes}),
      .tens(tens_minutes),
      .ones(ones_minutes)
  );

  binary_to_bcd bcd_seconds (
      .bin ({1'b0, seconds}),
      .tens(tens_seconds),
      .ones(ones_seconds)
  );

  // 6 seven_segment
  seven_segment #(
      .ACTIVE_LOW(32'(1))
  ) seconds_ones (
      .digit(ones_seconds),
      .blank(1'b0),
      .segments(HEX0)
  );

  seven_segment #(
      .ACTIVE_LOW(32'(1))
  ) seconds_tens (
      .digit(tens_seconds),
      .blank(1'b0),
      .segments(HEX1)
  );

  seven_segment #(
      .ACTIVE_LOW(32'(1))
  ) minutes_ones (
      .digit(ones_minutes),
      .blank(1'b0),
      .segments(HEX2)
  );

  seven_segment #(
      .ACTIVE_LOW(32'(1))
  ) minutes_tens (
      .digit(tens_minutes),
      .blank(1'b0),
      .segments(HEX3)
  );

  seven_segment #(
      .ACTIVE_LOW(32'(1))
  ) hours_ones (
      .digit(ones_hours),
      .blank(1'b0),
      .segments(HEX4)
  );

  seven_segment #(
      .ACTIVE_LOW(32'(1))
  ) hours_tens (
      .digit(tens_hours),
      .blank(1'b0),
      .segments(HEX5)
  );

endmodule

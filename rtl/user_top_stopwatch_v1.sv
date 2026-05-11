// ------------------------------------------------------------------
//
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module user_top_stopwatch_v1 #(
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
  // Driving unused outputs to 0
  assign led = '0;
  assign blank_hours = '0;
  assign blank_minutes = '0;
  assign blank_seconds = '0;

  /* Instantiate 2 rising_edge_detector for each button */
  // button[0]
  logic rise0;
  rising_edge_detector u_rise_edge_b0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise0)
  );

  // button[1]
  logic rise1;
  rising_edge_detector u_rise_edge_b1 (
      .clk(clk),
      .sig_in(button[1]),
      .rise(rise1)
  );

  // Instantiate snapshot_mux
  logic lap_hold;
  logic [6:0] minutes;
  logic [5:0] seconds;
  logic [6:0] centiseconds;

  snapshot_mux #(
      .WIDTH(21)
  ) u_snapshot_mux (
      .clk(clk),
      .hold(lap_hold),
      .d({minutes, 1'b0, seconds, centiseconds}),
      .q({hours_disp, minutes_disp, seconds_disp})
  );

  // Instantiate stopwatch_control
  logic counter_rst;
  logic counter_enable;
  stopwatch_control u_stopwatch_ctrl (
      .clk(clk),
      .rise_start_stop(rise0),
      .rise_lap(rise1),
      .counter_rst(counter_rst),
      .counter_enable(counter_enable),
      .lap_hold(lap_hold)
  );

  // Instantiate stopwatch_counter
  stopwatch_counter #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_stopwatch_counter (
      .clk(clk),
      .rst(counter_rst),
      .enable(counter_enable),
      .minutes(minutes),
      .seconds(seconds),
      .centiseconds(centiseconds)
  );

endmodule

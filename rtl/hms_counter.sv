// Counts seconds, minutes, hours and rollovers once seconds/minutes is hit
//
// Parameters:
// N_HOURS
// N_MINUTES
// N_SECONDS
//
// W_HOURS
// W_MINUTES
// W_SECONDS
//
// Ports :
// clk
// enable
// hours [1:0]
// minutes [1:0]
// seconds [1:0]
//
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module hms_counter #(
    parameter int N_HOURS   = 24,  //number of hours
    parameter int N_MINUTES = 60,  //number of minutes
    parameter int N_SECONDS = 60,  //number of seconds

    // Output port widths
    parameter int W_HOURS   = 5,
    parameter int W_MINUTES = 6,
    parameter int W_SECONDS = 6
) (
    input logic clk,
    input logic enable,
    output logic [W_HOURS-1:0] hours,
    output logic [W_MINUTES-1:0] minutes,
    output logic [W_SECONDS-1:0] seconds
);
  localparam logic [W_SECONDS-1:0] MaxSeconds = W_SECONDS'(N_SECONDS - 1);
  localparam logic [W_MINUTES-1:0] MaxMinutes = W_MINUTES'(N_MINUTES - 1);

  logic second_rollover;  // Rollover from sec to mins
  logic minute_rollover;  // Rollover from min to hour

  assign second_rollover = (seconds == MaxSeconds);
  assign minute_rollover = (minutes == MaxMinutes) & second_rollover;

  up_down_counter #(
      .MAX  (N_SECONDS - 1),
      .WIDTH(W_SECONDS)
  ) u_seconds (
      .clk(clk),
      .up(1'b1),
      .enable(enable),
      .count(seconds)
  );
  up_down_counter #(
      .MAX  (N_MINUTES - 1),
      .WIDTH(W_MINUTES)
  ) u_minute (
      .clk(clk),
      .up(1'b1),
      .enable(enable & second_rollover),
      .count(minutes)
  );
  up_down_counter #(
      .MAX  (N_HOURS - 1),
      .WIDTH(W_HOURS)
  ) u_hours (
      .clk(clk),
      .up(1'b1),
      .enable(enable & minute_rollover),
      .count(hours)
  );
endmodule

// Generates a PWM signal
// DUTY-CYCLE determines the ratio of "on" to "off"
//
// Parameters:
// PERIOD_CYCLES = 50_000_000
// DUTY_CYCLES = 25_000_000
// Ports :
// clk
// rst
// pwm_out
//
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLES = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input  logic clk,
    input  logic rst,
    output logic pwm_out
);
  localparam int WIDTH = 26;
  logic [WIDTH-1:0] count;

  mod_n_counter #(
      .N(PERIOD_CYCLES),
      .WIDTH(WIDTH)
  ) mod_counter (
      .clk(clk),
      .rst(rst),
      .enable(1'b1),
      .count(count)
  );

  assign pwm_out = (count < 26'(DUTY_CYCLES));

endmodule

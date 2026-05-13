// ------------------------------
//
// ------------------------------
`timescale 1ns / 1ps

module user_top_brightness_wrapper #(
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

  logic blank_h;
  logic blank_m;
  logic blank_s;

  user_top #(
      .CYCLES_PER_SECOND(CYCLES_PER_SECOND)
  ) u_user_top (
      .clk(clk),
      .button(button),
      .sw(sw),
      .led(led),
      .hours_disp(hours_disp),
      .minutes_disp(minutes_disp),
      .seconds_disp(seconds_disp),
      .blank_hours(blank_h),
      .blank_minutes(blank_m),
      .blank_seconds(blank_s)
  );

  localparam int PWMPeriod = CYCLES_PER_SECOND / 1000;
  localparam int CountWidth = $clog2(CYCLES_PER_SECOND);
  logic [CountWidth-1:0] count;
  mod_n_counter #(
      .N(PWMPeriod),
      .WIDTH(CountWidth)
  ) u_mod_n_counter (
      .clk(clk),
      .rst('0),
      .enable('1),
      .count(count)
  );

  logic [1:0] brightness_sw;
  assign brightness_sw = sw[9:8];

  logic [CountWidth-1:0] duty_cycle; // Check DUty Cycles
  always_comb begin
    case (brightness_sw)
      2'b00:   duty_cycle = CountWidth'(PWMPeriod / 8);  // 12.5% DUTY_CYCLE
      2'b01:   duty_cycle = CountWidth'(PWMPeriod / 4);  // 25.0% DUTY_CYCLE
      2'b10:   duty_cycle = CountWidth'(PWMPeriod);      // 100.0% DUTY_CYCLE
      2'b11:   duty_cycle = CountWidth'(PWMPeriod / 2);  // 50.0% DUTY_CYCLE
      default: duty_cycle = CountWidth'(PWMPeriod / 8);  // Default to 12.5%
    endcase
  end

  logic pwm_blank;
  assign pwm_blank = (count < (duty_cycle)) ? '0 : '1;

  // Output Logic
  assign blank_hours = blank_h || pwm_blank;
  assign blank_minutes = blank_m || pwm_blank;
  assign blank_seconds = blank_s || pwm_blank;

endmodule

// Seven-segment display decoder for hexadecimal digits.
//
// Parameters:
// ACTIVE_LOW - 1 for active - low LEDs (for example, DE1 - SoC), 0 for active - high.
//
// Ports :
// digit [3:0] - Hexadecimal digit to display (0 x0 to 0xF).
// blank - When high , all segments are turned off.
// segments [6:0] - Segment outputs [g,f,e,d,c,b,a].
// ------------------------------------------------------------------
`timescale 1ns / 1ps

module pwm_generator #(
    // Number of clock cycles in one PWM period
    parameter int PERIOD_CYCLE = 50_000_000,

    // Number of clock cycles output is high
    parameter int DUTY_CYCLES = 25_000_000
) (
    input logic clk,
    input logic rst,
    input logic pwm_out
);
    mod_n_counter #(
        .N(),
        .WIDTH()
    ) 
endmodule

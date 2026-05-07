// -------------------
// Formal Verification
// -------------------
`timescale 1ns / 1ps

module up_down_counter_rst_assert #(
    parameter int MAX   = 2,
    parameter int WIDTH = 2
) (
    input logic clk,
    input logic enable,
    input logic rst,
    input logic up,
    output logic [WIDTH-1:0] count
);

  up_down_counter_rst #(
      .MAX  (MAX),
      .WIDTH(WIDTH)
  ) u_counter (
      .clk(clk),
      .rst(rst),
      .enable(enable),
      .up(up),
      .count(count)
  );

  // verilog_lint: waive-start always-comb

  /* verilator lint_off WIDTHEXPAND */
  /* verilator lint_off BLKSEQ */

  // Ensure parameter values are sensible
  initial assert (MAX >= 0);
  initial assert ((1 << WIDTH) > MAX);

  // Ensure count remains within range at all times
  always @(*) assert (count <= MAX);

  // Detect start-up
  logic start = 1'b1;
  always @(posedge clk) start <= 1'b0;

  // Check initial value and reset value
  always @(posedge clk) if (start || $past(rst)) a_reset : assert (count == 0);

  // Check hold
  always @(posedge clk)
    if (!start && !$past(enable) && !$past(rst))
      a_hold : assert (count == $past(count));

  // Check count up
  logic wrap_up;
  always @(posedge clk) begin
    wrap_up = ($past(count) == MAX && count == 0);
    if (!start && $past(enable) && !$past(rst) && $past(up))
      a_count_up : assert (count == $past(count) + 1 || wrap_up);
  end

  // Check count down
  logic wrap_down;
  always @(posedge clk) begin
    wrap_down = ($past(count) == 0 && count == MAX);
    if (!start && $past(enable) && !$past(rst) && !$past(up))
      a_count_down : assert (count == $past(count) - 1 || wrap_down);
  end

endmodule

`timescale 1ns / 1ps
module wave_restartable_rate_generator_special;
  reg  clk = 0;
  reg  run = 0;
  wire tick;

  restartable_rate_generator #(
      .CYCLE_COUNT(1)
  ) dut (
      .clk (clk),
      .run (run),
      .tick(tick)
  );

  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_restartable_rate_generator_special.vcd");
    $dumpvars(0, wave_restartable_rate_generator_special);

    // Run: tick fires every CYCLE_COUNT clocks
    #30;
    run = 1;
    #40;
    run = 0;
    #25;
    run = 1;
    #20;
    run = 0;
    #5;
    run = 1;
    #5;
    run = 0;
    #10;
    run = 1;
    #5;
    run = 0;
    #30;
    run = 1;
    #90;
    run = 0;
    #20 $finish;
  end
endmodule

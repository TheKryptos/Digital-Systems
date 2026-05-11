`timescale 1ns/1ps
module wave_user_top_stopwatch_v1;
  reg        clk    = 0;
  reg  [3:0] button = 4'b0;
  reg  [9:0] sw     = 10'b0;
  wire [9:0] led;
  wire [6:0] hours_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire       blank_hours;
  wire       blank_minutes;
  wire       blank_seconds;

  // CYCLES_PER_SECOND=100 keeps the simulation concise:
  //   1 simulated second      = 100 cycles = 1000 ns
  //   1 simulated centisecond =   1 cycle  =   10 ns
  user_top_stopwatch_v1 #(
      .CYCLES_PER_SECOND(100)
  ) dut (
      .clk          (clk),
      .button       (button),
      .sw           (sw),
      .led          (led),
      .hours_disp   (hours_disp),
      .minutes_disp (minutes_disp),
      .seconds_disp (seconds_disp),
      .blank_hours  (blank_hours),
      .blank_minutes(blank_minutes),
      .blank_seconds(blank_seconds)
  );

  always #5 clk = ~clk;  // 100 MHz: 10 ns period

  initial begin
    $dumpfile("wave_user_top_stopwatch_v1.vcd");
    $dumpvars(0, wave_user_top_stopwatch_v1);

    // --- Initial State ---
    // Stopwatch is stopped at 00:00:00.
    #100;

    // --- Press Start ---
    // Pulse button[0]. The stopwatch transitions to RunningLive.
    // seconds_disp (centiseconds) will begin incrementing every 10ns.
    button[0] = 1;
    #10;           // Held for 1 clock cycle
    button[0] = 0;
    #500;          // Let it run for 50 cycles (50 centiseconds)

    // --- Press Lap (Freeze Display) ---
    // Pulse button[1] while running. Transitions to RunningFrozen.
    // Display outputs are held constant, but internal counter keeps going.
    button[1] = 1;
    #10;
    button[1] = 0;
    #500;          // Wait another 50 cycles (internal time reaches 1.00s)

    // --- Press Lap (Resume Display) ---
    // Pulse button[1] again. Transitions back to RunningLive.
    // Displays will instantly jump to catch up with the internal counter.
    button[1] = 1;
    #10;
    button[1] = 0;
    #300;          // Let it run for 30 more cycles

    // --- Press Stop ---
    // Pulse button[0]. Transitions to StoppedLive.
    // Counter stops incrementing.
    button[0] = 1;
    #10;
    button[0] = 0;
    #200;          // Wait a bit to observe it is stopped

    // --- Press Reset ---
    // Pulse button[1] while stopped. Transitions to Resetting.
    // Counter clears back to 0.
    button[1] = 1;
    #10;
    button[1] = 0;
    #200;          // Wait to observe the reset

    $finish;
  end
endmodule

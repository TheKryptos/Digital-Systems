`timescale 1ns/1ps

module wave_user_top_timer_s4;
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

  // CYCLES_PER_SECOND = 50 keeps the simulation concise:
  //   1 simulated second        = 50 cycles  = 500 ns
  //   PWM period (0.5 s)        = 25 cycles  = 250 ns  (2 Hz flash)
  //   PWM high (0.1 s)          =  5 cycles  =  50 ns  (display off, 20% of period)
  //   Mode-selector hold (1 s)  = 50 cycles  = 500 ns
  //   Auto-repeat hold (0.5 s)  = 25 cycles  = 250 ns
  //   Auto-repeat interval(0.1s)=  5 cycles  =  50 ns
  user_top_timer_v1 #(
      .CYCLES_PER_SECOND(50)
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
    $dumpfile("wave_user_top_timer_s4.vcd");
    $dumpvars(0, wave_user_top_timer_s4);

    // =========================================================
    // STATE 1: STOPPED at 00:00:00
    // =========================================================
    // Verify that pressing start when the timer is at zero does nothing.
    #250;
    button[0] = 1;
    #100;
    button[0] = 0;
    #250;

    // =========================================================
    // STATE 2: SET MODE
    // =========================================================
    // Long press KEY[3]: enter edit mode, seconds selected
    button[3] = 1; // FIX: Assert the button before waiting!
    #550;  // 55 cycles held (> HOLD_CYCLES=50) -> mode_enable = 3'b001
    button[3] = 0;
    #250;

    // Set seconds to 00:00:04 via 4 short taps of KEY[1] (inc)
    button[1] = 1; #100; button[1] = 0; #100; // Tap 1 -> 1s
    button[1] = 1; #100; button[1] = 0; #100; // Tap 2 -> 2s
    button[1] = 1; #100; button[1] = 0; #100; // Tap 3 -> 3s
    button[1] = 1; #100; button[1] = 0; #100; // Tap 4 -> 4s

    // Short press KEY[3]: cycle from seconds to minutes
    button[3] = 1; #100; button[3] = 0; #250;

    // Short press KEY[3]: cycle from minutes to hours
    button[3] = 1; #100; button[3] = 0; #250;

    // Short press KEY[3]: exit edit mode (returns to STOPPED)
    button[3] = 1; #100; button[3] = 0; #250;

    // =========================================================
    // STATE 3: RUNNING
    // =========================================================
    // Start the timer. Because time > 0, button[0] starts the countdown.
    button[0] = 1;
    #100;
    button[0] = 0;

    // Let it count down 1 simulated second (time is now 00:00:03)
    #500;

    // =========================================================
    // VERIFY LAYER 4 FIX: "Forceful Entry" Prevention
    // =========================================================
    // Try to hold button[3] while the timer is running.
    // It should completely ignore this and NOT enter set mode.
    button[3] = 1;
    #550; // Hold for 1+ seconds
    button[3] = 0;

    // =========================================================
    // STATE 4: AUTO-STOP
    // =========================================================
    // The timer should still be counting down from 00:00:03.
    // Wait 3.5 seconds to watch it hit 00:00:00 and automatically stop.
    #1750; // 50 cycles * 3.5 = 175 cycles = 1750 ns

    // Verify it is firmly stopped at zero. Pressing start should do nothing.
    button[0] = 1;
    #100;
    button[0] = 0;
    #500;

    $finish;
  end
endmodule

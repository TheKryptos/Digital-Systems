`timescale 1ns / 1ps

module wave_user_top_timer_s3;
  // Inputs
  reg        clk = 0;
  reg  [3:0] button = 0;
  reg  [9:0] sw = 0;

  // Outputs
  wire [9:0] led;
  wire [6:0] hours_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire       blank_hours;
  wire       blank_minutes;
  wire       blank_seconds;

  // Instantiate the Device Under Test (DUT)
  user_top_timer_v1 #(
      .CYCLES_PER_SECOND(2) // Keep ticks fast for the simulator
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

  // Clock generator: 10ns period (100 MHz)
  always #5 clk = ~clk;

  initial begin
    // Setup waveform dumping
    $dumpfile("wave_user_top_timer_s3.vcd");
    $dumpvars(0, wave_user_top_timer_s3);

    // Initialize inputs
    clk = 0;
    button = 0;
    sw = 0;

    // Wait for the circuit to settle.
    // Counters should currently output 00:00:00.
    #100;

    // ---------------------------------------------------------
    // TEST 1: The Underflow Prevention Test
    // ---------------------------------------------------------

    // Attempt to start the timer while it is at 00:00:00
    @(posedge clk) button[0] = 1;
    #20;
    @(posedge clk) button[0] = 0;

    // Wait 200ns (enough time for several ticks to fire if running was high).
    // WHAT TO LOOK FOR IN THE WAVEFORM:
    // -> If Layer 3 works: The counters will stay at 0, and the internal 'running'
    //    flag will either never go high, or will drop to 0 almost immediately.
    // -> If Layer 3 fails: You will see the counters roll over to 23:59:59.
    #200;

    $finish;
  end
endmodule

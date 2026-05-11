`timescale 1ns / 1ps

module wave_user_top_timer_s2;
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
  user_top_timer_s2 #(
      // reduce the cycle count for simulation speed
      .CYCLES_PER_SECOND(2)
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
    $dumpfile("wave_user_top_timer_s2.vcd");
    $dumpvars(0, wave_user_top_timer_s2);

    // Initialize inputs
    clk = 0;
    button = 0;
    sw = 0;

    // Timer does nothing while !running
    #100;

    // Start Timer by pressing button[0]
    @(posedge clk) button[0] = 1;
    #20;  // Hold for a couple of cycles
    @(posedge clk) button[0] = 0;

    // Timer counts down
    #200;

    // Pause timer
    @(posedge clk) button[0] = 1;
    #20;
    @(posedge clk) button[0] = 0;

    // Timer is paused
    #150;

    // Resume Timer
    @(posedge clk) button[0] = 1;
    #20;
    @(posedge clk) button[0] = 0;

    // Timer resumed
    #200;

    $finish;
  end
endmodule

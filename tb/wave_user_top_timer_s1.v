`timescale 1ns / 1ps

module wave_user_top_timer_s1;
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
  user_top_timer_s1 #(
      // reduce the cycle count for simulation speed
      .CYCLES_PER_SECOND(1)
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
    $dumpfile("wave_user_top_timer.vcd");
    $dumpvars(0, wave_user_top_timer_s1);

    // Initialize inputs
    clk = 0;
    button = 0;
    sw = 0;

    // Wait 100ns for initialization
    #100;

    // Show centiseconds rollover
    #3000;

    #500;
    $finish;
  end
endmodule

`timescale 1ns/1ps

module wave_user_top_brightness_wrapper;

  // Inputs
  reg clk = 0;
  reg [3:0] button = 0;
  reg [9:0] sw = 0;

  // Outputs
  wire [9:0] led;
  wire [6:0] hours_disp;
  wire [6:0] minutes_disp;
  wire [6:0] seconds_disp;
  wire blank_hours;
  wire blank_minutes;
  wire blank_seconds;

  // Instantiate the Unit Under Test (UUT)
  // Override CYCLES_PER_SECOND so 1ms period = 50 clock cycles (instead of 50,000)
  user_top_brightness_wrapper #(
      .CYCLES_PER_SECOND(50_000)
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

  // Clock generation (10 ns period -> 5 ns high, 5 ns low)
  always #5 clk = ~clk;

  initial begin
    $dumpfile("wave_user_top_brightness_wrapper.vcd");
    $dumpvars(0, wave_user_top_brightness_wrapper);

    // Test 1: Dim Brightness (sw[9:8] = 00, 12.5% duty cycle)
    sw[9:8] = 2'b00;
    #1500; // Run for 3 full PWM periods (3 * 50 cycles * 10 ns = 1500 ns)

    // Test 2: Low Brightness (sw[9:8] = 01, 25% duty cycle)
    sw[9:8] = 2'b01;
    #1500;

    // Test 3: Medium Brightness (sw[9:8] = 11, 50% duty cycle)
    // Note: This follows the Grey Code from the spec
    sw[9:8] = 2'b11;
    #1500;

    // Test 4: Full Brightness (sw[9:8] = 10, 100% duty cycle)
    sw[9:8] = 2'b10;
    #1500;

    // Test 5: Button Pass-Through Override
    // Set to dim so the PWM is mostly off, then press buttons to force
    // the inner dummy app to assert its own blanking.
    sw[9:8] = 2'b00;
    button[2:0] = 3'b111;
    #1000;

    // Finish simulation
    $finish;
  end

endmodule

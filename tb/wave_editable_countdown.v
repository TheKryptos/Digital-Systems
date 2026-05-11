`timescale 1ns / 1ps
module wave_editable_countdown;
  reg        clk = 0;
  reg        tick = 0;
  reg        clr = 0;
  reg        edit_mode = 0;
  reg        inc = 0;
  reg        dec = 0;
  wire [4:0] count;
  wire       borrow_out;

  editable_countdown #(
      .MAX(30),
      .WIDTH(5)
  ) dut (
      .clk       (clk),
      .clr       (clr),
      .tick      (tick),
      .edit_mode (edit_mode),
      .inc       (inc),
      .dec       (dec),
      .count     (count),
      .borrow_out(borrow_out)
  );

  always #5 clk = ~clk;

  // Tick pulses at a constant rate (every 30ns, 10ns high, 20ns low)
  always begin
    #20;
    tick = 1;
    #10;
    tick = 0;
  end

  initial begin
    $dumpfile("wave_editable_countdown.vcd");
    $dumpvars(0, wave_editable_countdown); // Fixed module name

    // Start in tick mode: count DECREMENTS on each tick
    #10;
    // Let a few ticks decrement the counter to observe the borrow_out pulse at 0
    #120;

    // Edit mode: tick pulses continue, but are ignored by the counter
    edit_mode = 1;
    inc = 1;
    // Manually incrementing the countdown timer
    #60;
    inc = 0;

    // Edit mode: manually decrementing
    #10;
    dec = 1;
    #60;
    dec = 0;

    // Both inc and dec asserted: count holds (enable is gated off)
    #10;
    inc = 1;
    dec = 1;
    #40;
    inc = 0;
    dec = 0;

    // Return to tick mode: countdown resumes on tick
    #20;
    edit_mode = 0;
    #90;

    // Test the clear function (should wipe to 0 and suppress borrow_out)
    clr = 1;
    #20;
    clr = 0;

    #40;
    $finish;
  end
endmodule

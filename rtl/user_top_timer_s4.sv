// ----------------------
// Timer Integration
// ----------------------
`timescale 1ns / 1ps

module user_top_timer_s4 #(
    /* verilator lint_off UNUSEDPARAM */
    parameter int CYCLES_PER_SECOND = 50_000_000
    /* verilator lint_on UNUSEDPARAM */
) (
`ifdef FORMAL
    output logic probe_running,
    output logic [2:0] probe_mode_enable,
`endif
    input logic clk,
    /* verilator lint_off UNUSED */
    input logic [3:0] button,
    input logic [9:0] sw,
    /* verilator lint_on UNUSED */
    output logic [9:0] led,
    output logic [6:0] hours_disp,
    output logic [6:0] minutes_disp,
    output logic [6:0] seconds_disp,
    output logic blank_hours,
    output logic blank_minutes,
    output logic blank_seconds
);

  // Driving unused outputs to 0
  assign led = '0;
  assign blank_hours = '0;
  assign blank_minutes = '0;
  assign blank_seconds = '0;

  logic tick;
  logic seconds_borrow;
  logic minutes_borrow;
  logic unused_borrow;

  // Hours
  logic hours_edit;
  logic hours_inc;
  logic hours_dec;
  logic [4:0] hours;

  editable_countdown #(
      .MAX  (23),
      .WIDTH(5)
  ) u_hours_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(minutes_borrow),
      .edit_mode(hours_edit),
      .inc(hours_inc),
      .dec(hours_dec),
      .count(hours),
      .borrow_out(unused_borrow)
  );

  // Minutes
  logic minutes_edit;
  logic minutes_inc;
  logic minutes_dec;
  logic [5:0] minutes;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_minutes_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(seconds_borrow),
      .edit_mode(minutes_edit),
      .inc(minutes_inc),
      .dec(minutes_dec),
      .count(minutes),
      .borrow_out(minutes_borrow)
  );

  // Seconds
  logic seconds_edit;
  logic seconds_inc;
  logic seconds_dec;
  logic [5:0] seconds;
  editable_countdown #(
      .MAX  (59),
      .WIDTH(6)
  ) u_seconds_countdown (
      .clk(clk),
      .clr(1'(0)),
      .tick(tick),
      .edit_mode(seconds_edit),
      .inc(seconds_inc),
      .dec(seconds_dec),
      .count(seconds),
      .borrow_out(seconds_borrow)
  );

  // Zero-extend counter values to display outputs
  assign hours_disp   = {2'b0, hours};
  assign minutes_disp = {1'b0, minutes};
  assign seconds_disp = {1'b0, seconds};

  // Counts down the timer at 1Hz tick
  logic running = '0;
  restartable_rate_generator #(
      .CYCLE_COUNT(CYCLES_PER_SECOND)  // ticks once every second
  ) u_restartable_rate_generator (
      .clk (clk),
      .run (running),
      .tick(tick)
  );


  // ----------------------------
  // FSM (STOPPED, RUNNING, SET)
  // ----------------------------

  // Editing modes
  logic editing_mode;
  assign seconds_edit = (mode_enable == 3'b001);
  assign minutes_edit = (mode_enable == 3'b010);
  assign hours_edit   = (mode_enable == 3'b100);
  assign editing_mode = seconds_edit || minutes_edit || hours_edit;


  // button[0] controls start/stop //
  logic rise;
  rising_edge_detector u_rise_edge_b0 (
      .clk(clk),
      .sig_in(button[0]),
      .rise(rise)
  );

  // Auto-Stop at Zero
  logic stop;
  assign stop = (seconds == 6'(0)) && (minutes == 6'(0)) && (hours == 5'(0));

  // Next-State Declaration
  logic next_running;


  // State Register
  always_ff @(posedge clk) begin
    running <= next_running;
  end

  // Next-State Logic running
  always_comb begin
    next_running = running;
    // Running goes low when in editing
    if (editing_mode) next_running = 1'b0;
    // Running goes low when timer finishes counting down
    else if (stop) next_running = 1'b0;
    // Inverts running on button[0] press
    else if (rise) next_running = !running;
  end

  // ---------------------------------
  // Edit Mode Integration (Set Mode)
  // ---------------------------------

  // Enters Edit Mode / Toggles between editing digits
  logic enter_edit;
  assign enter_edit = button[3] && !running;

  logic [2:0] mode_enable;
  edit_mode_selector #(
      .HOLD_CYCLES(CYCLES_PER_SECOND)
  ) u_set_mode (
      .clk(clk),
      .button(enter_edit),
      .mode_enable(mode_enable)
  );

  // Instantiate button_auto_repeat (2 Modes: Inc/Dec at 10Hz)
  logic inc_pulse;
  logic dec_pulse;

  // Increment
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5s hold
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // 10 Hz repeat
  ) u_inc_repeat (
      .clk(clk),
      .button(button[1]),
      .pulse(inc_pulse)
  );


  // Decrement
  button_auto_repeat #(
      .HOLD_CYCLES  (CYCLES_PER_SECOND / 2),  // 0.5s hold
      .REPEAT_CYCLES(CYCLES_PER_SECOND / 10)  // 10 Hz repeat
  ) u_dec_repeat (
      .clk(clk),
      .button(button[0]),
      .pulse(dec_pulse)
  );

  // Increment/Decrement Logic in Setting Mode
  assign seconds_inc = seconds_edit && inc_pulse;
  assign seconds_dec = seconds_edit && dec_pulse;
  assign minutes_inc = minutes_edit && inc_pulse;
  assign minutes_dec = minutes_edit && dec_pulse;
  assign hours_inc   = hours_edit && inc_pulse;
  assign hours_dec   = hours_edit && dec_pulse;


`ifdef FORMAL
  assign probe_running = running;
  assign probe_mode_enable = mode_enable;
`endif

endmodule

// -- ----- ----- ---- ----- ----- ----- ----- ---- ----- ----- ----- ----- ---- --
// decimal_display_driver
// -- ----- ----- ---- ----- ----- ----- ----- ---- ----- ----- ----- ----- ---- --
// Board - specific display driver for the DE1 - SoC HEX displays.
//
// This module presents three decimal values (0 -99) on the six
// seven - segment HEX displays (HEX5 .. HEX0).
// Each value uses two digits .
//
// The module accepts numeric values and blanking controls .
// Internally , it handles :
// - binary -to - BCD conversion
// - seven - segment decoding
// - digit blanking
// - active - low segment polarity
// ------------------------------------------------------------------
`timescale 1ns / 1ps



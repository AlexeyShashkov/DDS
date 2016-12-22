//% Global configuration file for DDS module.

`ifndef CONFIG_SV
`define CONFIG_SV

`timescale 1ns / 1ps

`define ASYNCHRONOUS_RESET

`ifdef ASYNCHRONOUS_RESET
    // Asynchronous reset.
    `define SYNC_OR_ASYNC_RESET , posedge rst
`else
    // Synchronous reset.
    `define SYNC_OR_ASYNC_RESET
`endif

//% Clock frequency for tests.
parameter P_CLK_PERIOD = 20;

//% Main DDS parameter set.
parameter P_PH_NUM_ACC_WIDTH = 32;
parameter P_ROM_WIDTH = 18;
parameter P_ROM_ADDR_WIDTH = 12;

//% This block define is for verification of optimized ROMs only. Undefine to compare with full ROMs.
`define QUARTER_SYMMETRY_OPTIMIZED_ROMS

//% Dithering Correction DDS gives + ~14 dB of SFDR compared to No Correction DDS.
//% Dithering Correction cannot be fully parametrized because LFSR is not parametrized, thus
//% the code inside `ifdef DITHERING_CORRECTION block must be rewritten for every parameter set.
//`define DITHERING_CORRECTION

//% Taylor Series Correction DDS gives + ~46 dB of SFDR compared to No Correction DDS.
`define TAYLOR_SERIES_CORRECTION

//% Combining Taylor Series Correction and Dithering Correction gives output quality of several
//% extra dB more than the output quality of only Dithering Correction DDS (and that is much less than
//% Taylor-Series-Correction-only DDS can provide). The code below ensures that Dithering Correction is
//% not included for Taylor Series Correction DDS.
`ifdef TAYLOR_SERIES_CORRECTION
    `undef DITHERING_CORRECTION
`endif

//% For certain parameter sets the third term of Taylor Series for sin(x) or cos(x) can be very small
//% and thus can be always rounded to zero. In this cases introduction of the third term will have
//% zero effect on the quality of output, but will only use extra resources.
`ifdef TAYLOR_SERIES_CORRECTION
    //`define TAYLOR_SERIES_THIRD_TERM
`endif

//% Undefining rounding key will enable truncation instead.
`ifdef TAYLOR_SERIES_CORRECTION
    `define ENABLE_ROUNDING_TO_NEAREST_FRACTION
`endif

//% Disabling overflow correction may induce serious signal error.
`ifdef TAYLOR_SERIES_CORRECTION
    //`define ENABLE_OVERFLOW_CORRECTION
`endif

//% For Two's Complement Code the absolute values of max value and min value are not equal, but
//% sine and cosine outputs are always symmetric ("+1" to "-1"). For Taylor Series correction it is practically
//% possible that the final sum be the biggest negative value due to rounding. Constrained output option forces this
//% value to the minimal sine or cosine value.
`ifdef TAYLOR_SERIES_CORRECTION
    //`define FORCE_CONSTRAINED_OUTPUT
`endif

`endif  // `ifndef CONFIG_SV

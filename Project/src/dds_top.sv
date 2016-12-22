`include "config.sv"

module dds_top
#(
    parameter PH_NUM_ACC_WIDTH = P_PH_NUM_ACC_WIDTH,
    parameter ROM_WIDTH = P_ROM_WIDTH,
    parameter ROM_ADDR_WIDTH = P_ROM_ADDR_WIDTH
)
(
    input clk,
    input ce,
    input rst,
    input [(PH_NUM_ACC_WIDTH-1):0] phase_inc,
    output signed [(ROM_WIDTH-1):0] minus_sin,
    output signed [(ROM_WIDTH-1):0] cos
);


`ifdef ENABLE_OVERFLOW_CORRECTION

//% These local parameters are used for overflow correction.
localparam MAX_POS = (2 ** (ROM_WIDTH - 1) - 1);
localparam MIN_NEG = -(2 ** (ROM_WIDTH - 1) - 1);

`endif  // `ifdef ENABLE_OVERFLOW_CORRECTION


`ifdef FORCE_CONSTRAINED_OUTPUT

//% This parameter is used for force-constraining output between +0.11[...]11 and -0.11[...]11.
localparam LESS_THAN_MIN_NEG = -(2 ** (ROM_WIDTH - 1));

`endif  // `ifdef FORCE_CONSTRAINED_OUTPUT


`ifndef DITHERING_CORRECTION


//% Phase number accumulator.
//% Current phase is (2 * PI * (phase_num_acc / (2 ^ PH_NUM_ACC_WIDTH))).
logic [(PH_NUM_ACC_WIDTH-1):0] phase_num_acc;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        phase_num_acc <= 1'b0;
    else if (ce)
    begin
        phase_num_acc <= (phase_num_acc + phase_inc);
    end
end


`else  // `ifndef DITHERING_CORRECTION


logic [9:0] pseudo_rand_word_0;
lfsr #(146501) lfsr_0
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .pseudo_rand_word(pseudo_rand_word_0)
);

logic [9:0] pseudo_rand_word_1;
lfsr #(71909) lfsr_1
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .pseudo_rand_word(pseudo_rand_word_1)
);

logic [19:0] dither_vector;
assign dither_vector = {pseudo_rand_word_0, pseudo_rand_word_1};

/*
//% This code is not synthesizeable and it is used for comparison.
always_ff @(posedge clk)
begin
    assert(std::randomize(dither_vector));
end
*/

//% Phase number accumulator.
//% Current phase is (2 * PI * (pre_phase_num_acc / (2 ^ PH_NUM_ACC_WIDTH))).
logic [(PH_NUM_ACC_WIDTH-1):0] phase_num_acc;
logic [(PH_NUM_ACC_WIDTH-1):0] pre_phase_num_acc;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        pre_phase_num_acc <= 1'b0;
    else if (ce)
    begin
        pre_phase_num_acc <= (pre_phase_num_acc + phase_inc);
    end
end

always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        phase_num_acc <= 1'b0;
    else if (ce)
    begin
        phase_num_acc <= (pre_phase_num_acc + dither_vector);
    end
end

`endif  // `ifndef DITHERING_CORRECTION


//% ROM address is the highest ROM_ADDR_WIDTH bits of phase_num_acc.
logic [(ROM_ADDR_WIDTH-1):0] addr;
assign addr = phase_num_acc[(PH_NUM_ACC_WIDTH-1):(PH_NUM_ACC_WIDTH-ROM_ADDR_WIDTH)];

logic [ROM_WIDTH-1:0] rom_minus_sin_value;
logic [ROM_WIDTH-1:0] rom_cos_value;


`ifdef QUARTER_SYMMETRY_OPTIMIZED_ROMS


minus_sin_sym_opt_rom #(ROM_ADDR_WIDTH, ROM_WIDTH) minus_sin_rom_0
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .addr(addr),
    .minus_sin_value(rom_minus_sin_value)
);

cos_sym_opt_rom #(ROM_ADDR_WIDTH, ROM_WIDTH) cos_rom_0
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .addr(addr),
    .cos_value(rom_cos_value)
);


`else  // `ifdef QUARTER_SYMMETRY_OPTIMIZED_ROMS


minus_sin_rom #(ROM_ADDR_WIDTH, ROM_WIDTH) minus_sin_rom_0
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .addr(addr),
    .minus_sin_value(rom_minus_sin_value)
);

cos_rom #(ROM_ADDR_WIDTH, ROM_WIDTH) cos_rom_0
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .addr(addr),
    .cos_value(rom_cos_value)
);


`endif  // `ifdef QUARTER_SYMMETRY_OPTIMIZED_ROMS


`ifndef TAYLOR_SERIES_CORRECTION


//% No Taylor Series error correction.
assign minus_sin = rom_minus_sin_value;
assign cos = rom_cos_value;


`else  // `ifndef TAYLOR_SERIES_CORRECTION


//% Taylor Series approximation correction (two terms or three terms only).
//% -sin(x) ~= -sin(a) - ((x-a) * cos(a)) - (1/2 * (x-a)^2 * -sin(a)).
//% cos(x) ~= cos(a) + ((x-a) * -sin(a)) + (1/2 * (x-a)^2 * cos(a)).

//% Taylor Series approximation correction: phase error (x-a) calculation.
//% acc_num_error takes bits that are not used in the address of ROMs.
logic [(PH_NUM_ACC_WIDTH-ROM_ADDR_WIDTH-1):0] acc_num_error;
assign acc_num_error = phase_num_acc[(PH_NUM_ACC_WIDTH-ROM_ADDR_WIDTH-1):0];

localparam K = 201;  // K ~= PI * 2^-6 = PI * 2^-T .
localparam T = 6;
localparam K_WIDTH = 8;  //% K = 'd201 = 8'b11001001.
localparam PHASE_ERROR_WIDTH = (PH_NUM_ACC_WIDTH - ROM_ADDR_WIDTH) + K_WIDTH;
logic [(PHASE_ERROR_WIDTH-1):0] w_phase_error, r_phase_error;
assign w_phase_error = (K * acc_num_error);

always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_phase_error <= 1'b0;
    else if (ce)
        r_phase_error <= w_phase_error;
end

//% For 32-bit accumulator: signed phase_error_full = 2^-31 * PI * acc_num_error =
//% = 2^-31 * K * 2^-T * acc_num_error = 2^-(31+T) * K * acc_num_error.
//% One additional bit is for sign bit 0.
localparam PH_ERR_FULL_WIDTH = (PH_NUM_ACC_WIDTH + T);
logic signed [(PH_ERR_FULL_WIDTH-1):0] phase_error_full;
always_comb
begin
    phase_error_full[(PH_ERR_FULL_WIDTH-1):PHASE_ERROR_WIDTH] = 1'b0;
    phase_error_full[(PHASE_ERROR_WIDTH-1):0] = r_phase_error;
end

logic signed [(ROM_WIDTH-1):0] rounded_phase_error;

logic signed [(ROM_WIDTH-1):0] pre_rounded_phase_error;
assign pre_rounded_phase_error = phase_error_full[(PH_ERR_FULL_WIDTH-1):(PH_ERR_FULL_WIDTH-ROM_WIDTH)];

`ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

always_comb
begin
    if (phase_error_full[PH_ERR_FULL_WIDTH-ROM_WIDTH-1])
        rounded_phase_error = pre_rounded_phase_error + 1'b1;
    else
        rounded_phase_error = pre_rounded_phase_error;
end

`else  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

assign rounded_phase_error = pre_rounded_phase_error;

`endif  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION


//% Taylor Series approximation: minus_sin feed-forward logic.

logic signed [(2*ROM_WIDTH-1):0] minus_sin_error_div_2;
signed_mult #(ROM_WIDTH) s_mult_minus_sin_error
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .a(rounded_phase_error),
    .b(rom_cos_value),
    .a_mult_b(minus_sin_error_div_2)
);

logic signed [(2*ROM_WIDTH-1):0] minus_sin_error;
assign minus_sin_error = (minus_sin_error_div_2 << 1);

logic signed [(ROM_WIDTH-1):0] rounded_minus_sin_error;
logic signed [(ROM_WIDTH-1):0] pre_rounded_minus_sin_error;
assign pre_rounded_minus_sin_error = minus_sin_error[(2*ROM_WIDTH-1):ROM_WIDTH];

`ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

always_comb
begin
    if ( (~minus_sin_error[2*ROM_WIDTH-1] & minus_sin_error[ROM_WIDTH-1])
         |
         (minus_sin_error[2*ROM_WIDTH-1] & minus_sin_error[ROM_WIDTH-1] & |minus_sin_error[(ROM_WIDTH-2):0]) )
    begin
        rounded_minus_sin_error = pre_rounded_minus_sin_error + 1'b1;
    end
    else
    begin
        rounded_minus_sin_error = pre_rounded_minus_sin_error;
    end
end

`else  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

assign rounded_minus_sin_error = pre_rounded_minus_sin_error;

`endif  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

//% Delaying rom_minus_sin_value.
logic signed [(ROM_WIDTH-1):0] d_rom_minus_sin_value;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        d_rom_minus_sin_value <= 1'b0;
    else if (ce)
        d_rom_minus_sin_value <= rom_minus_sin_value;
end

`ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr_minus_sin;
logic signed [ROM_WIDTH:0] ovf_corr_minus_sin;
assign ovf_corr_minus_sin = d_rom_minus_sin_value - rounded_minus_sin_error;

always_comb
begin
    case (ovf_corr_minus_sin[ROM_WIDTH:(ROM_WIDTH-1)])
        2'b01 : corr_minus_sin = MAX_POS;  // Overflow.
        2'b10 : corr_minus_sin = MIN_NEG;  // Underflow.
        default : corr_minus_sin = ovf_corr_minus_sin[(ROM_WIDTH-1):0];  // In-range.
    endcase
end

`else  // `ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr_minus_sin;
assign corr_minus_sin = d_rom_minus_sin_value - rounded_minus_sin_error;

`endif  // `ifdef ENABLE_OVERFLOW_CORRECTION


`ifndef TAYLOR_SERIES_THIRD_TERM


logic signed [(ROM_WIDTH-1):0] sel_minus_sin;
assign sel_minus_sin = corr_minus_sin;


`else  // `ifndef TAYLOR_SERIES_THIRD_TERM


logic signed [(2*PH_ERR_FULL_WIDTH-1):0] sq_phase_error_div_2;
signed_mult #(PH_ERR_FULL_WIDTH) s_mult_sq_phase_error
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .a(phase_error_full),
    .b(phase_error_full),
    .a_mult_b(sq_phase_error_div_2)
);

logic signed [(ROM_WIDTH-1):0] rounded_sq_phase_error_div_2;
logic signed [(ROM_WIDTH-1):0] pre_rounded_sq_phase_error_div_2;
assign pre_rounded_sq_phase_error_div_2 =
    sq_phase_error_div_2[(2*PH_ERR_FULL_WIDTH-1):(2*PH_ERR_FULL_WIDTH-ROM_WIDTH)];

always_comb
begin
    if ( (~sq_phase_error_div_2[2*PH_ERR_FULL_WIDTH-1] & sq_phase_error_div_2[2*PH_ERR_FULL_WIDTH-ROM_WIDTH-1])
         |
         (sq_phase_error_div_2[2*PH_ERR_FULL_WIDTH-1] & sq_phase_error_div_2[2*PH_ERR_FULL_WIDTH-ROM_WIDTH-1] &
             |sq_phase_error_div_2[(2*PH_ERR_FULL_WIDTH-ROM_WIDTH-2):0]) )
    begin
        rounded_sq_phase_error_div_2 = pre_rounded_sq_phase_error_div_2 + 1'b1;
    end
    else
    begin
        rounded_sq_phase_error_div_2 = pre_rounded_sq_phase_error_div_2;
    end
end

//% Delaying corr_minus_sin.
logic signed [(ROM_WIDTH-1):0] d_corr_minus_sin;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        d_corr_minus_sin <= 1'b0;
    else if (ce)
        d_corr_minus_sin <= corr_minus_sin;
end

logic signed [(2*ROM_WIDTH-1):0] minus_sin_error_3rd_term_div_2;
signed_mult #(ROM_WIDTH) s_mult_minus_sin_3rd_term_error
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .a(rounded_sq_phase_error_div_2),
    .b(d_rom_minus_sin_value),
    .a_mult_b(minus_sin_error_3rd_term_div_2)
);

logic signed [(2*ROM_WIDTH-1):0] minus_sin_error_3rd_term;
assign minus_sin_error_3rd_term = (minus_sin_error_3rd_term_div_2 << 1);

logic signed [(ROM_WIDTH-1):0] rounded_minus_sin_error_3rd_term;
logic signed [(ROM_WIDTH-1):0] pre_rounded_minus_sin_error_3rd_term;
assign pre_rounded_minus_sin_error_3rd_term = minus_sin_error_3rd_term[(2*ROM_WIDTH-1):ROM_WIDTH];

`ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

always_comb
begin
    if ( (~minus_sin_error_3rd_term[2*ROM_WIDTH-1] & minus_sin_error_3rd_term[ROM_WIDTH-1])
         |
         (minus_sin_error_3rd_term[2*ROM_WIDTH-1] & minus_sin_error_3rd_term[ROM_WIDTH-1] &
             |minus_sin_error_3rd_term[(ROM_WIDTH-2):0]) )
    begin
        rounded_minus_sin_error_3rd_term = pre_rounded_minus_sin_error_3rd_term + 1'b1;
    end
    else
    begin
        rounded_minus_sin_error_3rd_term = pre_rounded_minus_sin_error_3rd_term;
    end
end

`else  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

assign rounded_minus_sin_error_3rd_term = pre_rounded_minus_sin_error_3rd_term;

`endif  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION


`ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr2_minus_sin;
logic signed [ROM_WIDTH:0] ovf_corr2_minus_sin;
assign ovf_corr2_minus_sin = d_corr_minus_sin - rounded_minus_sin_error_3rd_term;

always_comb
begin
    case (ovf_corr_minus_sin[ROM_WIDTH:(ROM_WIDTH-1)])
        2'b01 : corr2_minus_sin = MAX_POS;  // Overflow.
        2'b10 : corr2_minus_sin = MIN_NEG;  // Underflow.
        default : corr2_minus_sin = ovf_corr2_minus_sin[(ROM_WIDTH-1):0];  // In-range.
    endcase
end

`else  // `ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr2_minus_sin;
assign corr2_minus_sin = d_corr_minus_sin - rounded_minus_sin_error_3rd_term;

`endif  // `ifdef ENABLE_OVERFLOW_CORRECTION


logic signed [(ROM_WIDTH-1):0] sel_minus_sin;
assign sel_minus_sin = corr2_minus_sin;


`endif  // `ifndef TAYLOR_SERIES_THIRD_TERM


`ifdef FORCE_CONSTRAINED_OUTPUT


logic signed [(ROM_WIDTH-1):0] constrained_minus_sin;
logic signed [(ROM_WIDTH-1):0] less_than_min_neg_bits;
assign less_than_min_neg_bits = LESS_THAN_MIN_NEG;
always_comb
begin
    if (sel_minus_sin == less_than_min_neg_bits)
        constrained_minus_sin = MIN_NEG;
    else
        constrained_minus_sin = sel_minus_sin;
end

logic signed [(ROM_WIDTH-1):0] r_minus_sin;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_minus_sin <= 1'b0;
    else if (ce)
        r_minus_sin <= constrained_minus_sin;
end


`else  // `ifdef FORCE_CONSTRAINED_OUTPUT


logic signed [(ROM_WIDTH-1):0] r_minus_sin;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_minus_sin <= 1'b0;
    else if (ce)
        r_minus_sin <= sel_minus_sin;
end


`endif  // `ifdef FORCE_CONSTRAINED_OUTPUT


//% Final minus_sin value.
assign minus_sin = r_minus_sin;


//% Taylor Series approximation: cos feed-forward logic.

logic signed [(2*ROM_WIDTH-1):0] cos_error_div_2;
signed_mult #(ROM_WIDTH) s_mult_cos_error
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .a(rounded_phase_error),
    .b(rom_minus_sin_value),
    .a_mult_b(cos_error_div_2)
);

logic signed [(2*ROM_WIDTH-1):0] cos_error;
assign cos_error = (cos_error_div_2 << 1);

logic signed [(ROM_WIDTH-1):0] rounded_cos_error;
logic signed [(ROM_WIDTH-1):0] pre_rounded_cos_error;
assign pre_rounded_cos_error = cos_error[(2*ROM_WIDTH-1):ROM_WIDTH];

`ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

always_comb
begin
    if ( (~cos_error[2*ROM_WIDTH-1] & cos_error[ROM_WIDTH-1])
         |
         (cos_error[2*ROM_WIDTH-1] & cos_error[ROM_WIDTH-1] & |cos_error[(ROM_WIDTH-2):0]) )
    begin
        rounded_cos_error = pre_rounded_cos_error + 1'b1;
    end
    else
    begin
        rounded_cos_error = pre_rounded_cos_error;
    end
end

`else  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

assign rounded_cos_error = pre_rounded_cos_error;

`endif  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION


//% Delaying rom_cos_value.
logic signed [(ROM_WIDTH-1):0] d_rom_cos_value;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        d_rom_cos_value <= 1'b0;
    else if (ce)
        d_rom_cos_value <= rom_cos_value;
end


`ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr_cos;
logic signed [ROM_WIDTH:0] ovf_corr_cos;
assign ovf_corr_cos = d_rom_cos_value + rounded_cos_error;

always_comb
begin
    case (ovf_corr_cos[ROM_WIDTH:(ROM_WIDTH-1)])
        2'b01 : corr_cos = MAX_POS;  // Overflow.
        2'b10 : corr_cos = MIN_NEG;  // Underflow.
        default : corr_cos = ovf_corr_cos[(ROM_WIDTH-1):0];  // In-range.
    endcase
end

`else  // `ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr_cos;
assign corr_cos = d_rom_cos_value + rounded_cos_error;

`endif  // `ifdef ENABLE_OVERFLOW_CORRECTION


`ifndef TAYLOR_SERIES_THIRD_TERM


logic signed [(ROM_WIDTH-1):0] sel_cos;
assign sel_cos = corr_cos;


`else  // `ifndef TAYLOR_SERIES_THIRD_TERM


//% Delaying corr_cos.
logic signed [(ROM_WIDTH-1):0] d_corr_cos;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        d_corr_cos <= 1'b0;
    else if (ce)
        d_corr_cos <= corr_cos;
end

logic signed [(2*ROM_WIDTH-1):0] cos_error_3rd_term_div_2;
signed_mult #(ROM_WIDTH) s_mult_cos_3rd_term_error
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .a(rounded_sq_phase_error_div_2),
    .b(d_rom_cos_value),
    .a_mult_b(cos_error_3rd_term_div_2)
);

logic signed [(2*ROM_WIDTH-1):0] cos_error_3rd_term;
assign cos_error_3rd_term = (cos_error_3rd_term_div_2 << 1);

logic signed [(ROM_WIDTH-1):0] rounded_cos_error_3rd_term;
logic signed [(ROM_WIDTH-1):0] pre_rounded_cos_error_3rd_term;
assign pre_rounded_cos_error_3rd_term = cos_error_3rd_term[(2*ROM_WIDTH-1):ROM_WIDTH];

`ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

always_comb
begin
    if ( (~cos_error_3rd_term[2*ROM_WIDTH-1] & cos_error_3rd_term[ROM_WIDTH-1])
         |
         (cos_error_3rd_term[2*ROM_WIDTH-1] & cos_error_3rd_term[ROM_WIDTH-1] &
             |cos_error_3rd_term[(ROM_WIDTH-2):0]) )
    begin
        rounded_cos_error_3rd_term = pre_rounded_cos_error_3rd_term + 1'b1;
    end
    else
    begin
        rounded_cos_error_3rd_term = pre_rounded_cos_error_3rd_term;
    end
end

`else  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION

assign rounded_cos_error_3rd_term = pre_rounded_cos_error_3rd_term;

`endif  // `ifdef ENABLE_ROUNDING_TO_NEAREST_FRACTION


`ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr2_cos;
logic signed [ROM_WIDTH:0] ovf_corr2_cos;
assign ovf_corr2_cos = d_corr_cos + rounded_cos_error_3rd_term;

always_comb
begin
    case (ovf_corr_cos[ROM_WIDTH:(ROM_WIDTH-1)])
        2'b01 : corr2_cos = MAX_POS;  // Overflow.
        2'b10 : corr2_cos = MIN_NEG;  // Underflow.
        default : corr2_cos = ovf_corr2_cos[(ROM_WIDTH-1):0];  // In-range.
    endcase
end

`else  // `ifdef ENABLE_OVERFLOW_CORRECTION

logic signed [(ROM_WIDTH-1):0] corr2_cos;
assign corr2_cos = d_corr_cos + rounded_cos_error_3rd_term;

`endif  // `ifdef ENABLE_OVERFLOW_CORRECTION


logic signed [(ROM_WIDTH-1):0] sel_cos;
assign sel_cos = corr2_cos;


`endif  // `ifndef TAYLOR_SERIES_THIRD_TERM


`ifdef FORCE_CONSTRAINED_OUTPUT


logic signed [(ROM_WIDTH-1):0] constrained_cos;
always_comb
begin
    if (sel_cos == less_than_min_neg_bits)
        constrained_cos = MIN_NEG;
    else
        constrained_cos = sel_cos;
end

logic signed [(ROM_WIDTH-1):0] r_cos;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_cos <= 1'b0;
    else if (ce)
        r_cos <= constrained_cos;
end


`else  // `ifdef FORCE_CONSTRAINED_OUTPUT


logic signed [(ROM_WIDTH-1):0] r_cos;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_cos <= 1'b0;
    else if (ce)
        r_cos <= sel_cos;
end


`endif  // `ifdef FORCE_CONSTRAINED_OUTPUT


//% Final cos value.
assign cos = r_cos;


`endif  // `ifndef TAYLOR_SERIES_CORRECTION


endmodule: dds_top

`include "config.sv"

module lfsr #(parameter N = 1)
(
    input clk,
    input ce,
    input rst,
    output [9:0] pseudo_rand_word
);

logic [9:0] r_lfsr;

logic [9:0] w_pseudo_rand_word;
always_comb
begin
    w_pseudo_rand_word[0] = r_lfsr[9] ^ r_lfsr[0];
    w_pseudo_rand_word[1] = r_lfsr[8] ^ r_lfsr[6] ^ r_lfsr[2];
    w_pseudo_rand_word[2] = r_lfsr[7] ^ r_lfsr[3] ^ r_lfsr[2] ^ r_lfsr[0];
    w_pseudo_rand_word[3] = r_lfsr[9] ^ r_lfsr[7] ^ r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[1];
    w_pseudo_rand_word[4] = r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[3] ^ r_lfsr[2] ^ r_lfsr[1] ^ r_lfsr[0];
    w_pseudo_rand_word[5] = r_lfsr[7] ^ r_lfsr[6] ^ r_lfsr[4] ^ r_lfsr[3] ^ r_lfsr[2] ^ r_lfsr[1] ^ r_lfsr[0];
    w_pseudo_rand_word[6] = r_lfsr[8] ^ r_lfsr[7] ^ r_lfsr[6] ^ r_lfsr[4] ^ r_lfsr[3] ^ r_lfsr[2] ^ r_lfsr[1] ^
                            r_lfsr[0];
    w_pseudo_rand_word[7] = r_lfsr[9] ^ r_lfsr[8] ^ r_lfsr[7] ^ r_lfsr[6] ^ r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[3] ^
                            r_lfsr[2] ^ r_lfsr[0];
    w_pseudo_rand_word[8] = r_lfsr[9] ^ r_lfsr[8] ^ r_lfsr[7] ^ r_lfsr[6] ^ r_lfsr[5] ^ r_lfsr[4] ^ r_lfsr[3] ^
                            r_lfsr[2] ^ r_lfsr[1] ^ r_lfsr[0];
    w_pseudo_rand_word[9] = r_lfsr[4] ^ r_lfsr[3] ^ r_lfsr[2] ^ r_lfsr[1];
end

logic feedback;
assign feedback = w_pseudo_rand_word[5];

always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_lfsr <= N;
    else if (ce)
        r_lfsr <= {feedback, r_lfsr[9:1]};
end

logic [9:0] r_pseudo_rand_word;
always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_pseudo_rand_word <= 1'b0;
    else if (ce)
        r_pseudo_rand_word <= w_pseudo_rand_word;
end
assign pseudo_rand_word = r_pseudo_rand_word;

endmodule: lfsr

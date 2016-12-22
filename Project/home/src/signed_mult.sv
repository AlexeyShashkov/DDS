`include "config.sv"

module signed_mult #(parameter N = 18)
(
    input clk,
    input ce,
    input rst,
    input signed [(N-1):0] a,
    input signed [(N-1):0] b,
    output signed [(2*N-1):0] a_mult_b
);

logic signed [(2*N-1):0] w_a_mult_b;
assign w_a_mult_b = a * b;

logic signed [(2*N-1):0] r_a_mult_b;

always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_a_mult_b <= 1'b0;
    else if (ce)
        r_a_mult_b <= w_a_mult_b;
end

assign a_mult_b = r_a_mult_b;

endmodule: signed_mult

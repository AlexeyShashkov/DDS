`include "config.sv"

module signed_mult_tb();

parameter N = 18;

logic clk, ce, rst;
logic signed [(N-1):0] a, b;
logic signed [(2*N-1):0] a_mult_b;

signed_mult #(N) dut
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .a(a),
    .b(b),
    .a_mult_b(a_mult_b)
);

always #(P_CLK_PERIOD/2) clk = ~clk;

initial
begin
    clk = 1;
    ce = 1;

    a = 2;
    b = 1;

    rst = 0;
    @(posedge clk);
    rst = 1;
    @(posedge clk);
    rst = 0;

    for (int i = 0; i < 10; i++)
    begin
        @(posedge clk);
        a--;
        b++;
    end
end

endmodule: signed_mult_tb

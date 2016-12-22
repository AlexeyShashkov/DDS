`include "config.sv"

module minus_sin_rom_tb();

parameter N = 15;

parameter ROM_ADDR_BITS = 12;
parameter ROM_WIDTH = 18;

logic clk, ce, rst;
logic [ROM_ADDR_BITS-1:0] addr;
logic [ROM_WIDTH-1:0] minus_sin_value;

minus_sin_rom #(ROM_ADDR_BITS, ROM_WIDTH) dut
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .addr(addr),
    .minus_sin_value(minus_sin_value)
);

always #(P_CLK_PERIOD/2) clk = ~clk;

initial
begin
    clk = 1;
    ce = 1;
    addr = 0;

    rst = 0;
    @(posedge clk);
    rst = 1;
    @(posedge clk);
    rst = 0;

    for (int i = 0; i < N; i++)
    begin
        @(posedge clk);
        addr++;
    end
end

endmodule: minus_sin_rom_tb

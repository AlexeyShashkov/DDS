`include "config.sv"

module cos_rom #(parameter ROM_ADDR_WIDTH = 12, parameter ROM_WIDTH = 18)
(
    input clk,
    input ce,
    input rst,
    input [ROM_ADDR_WIDTH-1:0] addr,
    output [ROM_WIDTH-1:0] cos_value
);

logic [ROM_WIDTH-1:0] w_cos_rom [(2**ROM_ADDR_WIDTH)-1:0];

//% Initialize w_cos_rom with the values from cos_wave.list file.
initial
begin
    $readmemb("./src/cos_wave_full.list", w_cos_rom, 0, ((2**ROM_ADDR_WIDTH)-1));
end

logic [ROM_WIDTH-1:0] r_cos_value;

always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_cos_value <= 1'b0;
    else if (ce)
        r_cos_value <= w_cos_rom[addr];
end

assign cos_value = r_cos_value;

endmodule: cos_rom

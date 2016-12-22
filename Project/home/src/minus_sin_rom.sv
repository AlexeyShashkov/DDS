`include "config.sv"

module minus_sin_rom #(parameter ROM_ADDR_WIDTH = 12, parameter ROM_WIDTH = 18)
(
    input clk,
    input ce,
    input rst,
    input [ROM_ADDR_WIDTH-1:0] addr,
    output [ROM_WIDTH-1:0] minus_sin_value
);

logic [ROM_WIDTH-1:0] w_minus_sin_rom [(2**ROM_ADDR_WIDTH)-1:0];

//% Initialize w_minus_sin_rom with the values from minus_sin_wave.list file.
initial
begin
    $readmemb("./src/minus_sin_wave_full.list", w_minus_sin_rom, 0, ((2**ROM_ADDR_WIDTH)-1));
end

logic [ROM_WIDTH-1:0] r_minus_sin_value;

always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_minus_sin_value <= 1'b0;
    else if (ce)
        r_minus_sin_value <= w_minus_sin_rom[addr];
end

assign minus_sin_value = r_minus_sin_value;

endmodule: minus_sin_rom

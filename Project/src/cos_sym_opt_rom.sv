`include "config.sv"

module cos_sym_opt_rom #(parameter ROM_ADDR_WIDTH = 12, parameter ROM_WIDTH = 18)
(
    input clk,
    input ce,
    input rst,
    input [ROM_ADDR_WIDTH-1:0] addr,
    output [ROM_WIDTH-1:0] cos_value
);

logic [ROM_WIDTH-1:0] w_cos_rom [((2**ROM_ADDR_WIDTH)/4):0];

//% Initialize w_cos_rom with the values from cos_wave.list file.
initial
begin
    $readmemb("./src/cos_wave_quarter.list", w_cos_rom, 0, ((2**ROM_ADDR_WIDTH)/4));
end

logic [ROM_ADDR_WIDTH-1:0] opt_addr;
always_comb
begin
    case (addr[(ROM_ADDR_WIDTH-1):(ROM_ADDR_WIDTH-2)])
        2'b00 : opt_addr = addr;
        2'b01 : opt_addr = (((2**ROM_ADDR_WIDTH)/2) - addr);
        2'b10 : opt_addr = (addr - ((2**ROM_ADDR_WIDTH)/2));
        default : opt_addr = ((2**ROM_ADDR_WIDTH) - addr);
    endcase
end

logic signed [ROM_WIDTH-1:0] opt_cos_value;
always_comb
begin
    case (addr[(ROM_ADDR_WIDTH-1):(ROM_ADDR_WIDTH-2)])
        2'b00 : opt_cos_value = w_cos_rom[opt_addr];
        2'b01 : opt_cos_value = -(w_cos_rom[opt_addr]);
        2'b10 : opt_cos_value = -(w_cos_rom[opt_addr]);
        default : opt_cos_value = w_cos_rom[opt_addr];
    endcase
end

logic [ROM_WIDTH-1:0] r_cos_value;

always_ff @(posedge clk `SYNC_OR_ASYNC_RESET)
begin
    if (rst)
        r_cos_value <= 1'b0;
    else if (ce)
        r_cos_value <= opt_cos_value;
end

assign cos_value = r_cos_value;

endmodule: cos_sym_opt_rom

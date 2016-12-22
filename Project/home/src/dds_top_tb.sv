`include "config.sv"

module dds_top_tb();

localparam PH_NUM_ACC_WIDTH = 32;
localparam ROM_WIDTH = 18;
localparam ROM_ADDR_WIDTH = 12;

logic clk, ce, rst;
logic [(PH_NUM_ACC_WIDTH-1):0] phase_inc;
logic signed [(ROM_WIDTH-1):0] minus_sin;
logic signed [(ROM_WIDTH-1):0] cos;


localparam D1 = 1_048_576;       // -sin: 130.34 dB, cos: 130.30 dB
localparam D2 = 10_485_760;      // -sin: 126.24 dB, cos: 126.24 dB
localparam D2_1 = 50_485_760;    // -sin: 118.19 dB, cos: 118.13 dB
localparam D3 = 100_485_760;     // -sin: 118.51 dB, cos: 117.46 dB
localparam D4 = 200_485_760;     // -sin: 117.59 dB, cos: 118.39 dB
localparam D5 = 300_485_760;     // -sin: 117.52 dB, cos: 117.82 dB
localparam D6 = 400_485_760;     // -sin: 118.05 dB, cos: 118.03 dB
localparam D7_M2 = 428_496_729;  // -sin: 117.13 dB, cos: 118.45 dB
localparam D7_M1 = 429_496_729;  // -sin: 108.25 dB, cos: 107.09 dB: this frequency should be avoided
localparam D7_0 = 429_496_730;   // -sin: 113.03 dB, cos: 106.31 dB: this frequency should be avoided
localparam D7_1 = 430_496_730;   // -sin: 118.38 dB, cos: 117.75 dB
localparam D8 = 450_485_760;     // -sin: 118.24 dB, cos: 118.62 dB
localparam D9 = 850_485_760;     // -sin: 118.19 dB, cos: 118.44 dB

localparam PH_NUM_DELTA = D9;


assign phase_inc = PH_NUM_DELTA;

dds_top #(PH_NUM_ACC_WIDTH, ROM_WIDTH, ROM_ADDR_WIDTH) dut
(
    .clk(clk),
    .ce(ce),
    .rst(rst),
    .phase_inc(phase_inc),
    .minus_sin(minus_sin),
    .cos(cos)
);

always #(P_CLK_PERIOD/2) clk = ~clk;

initial
begin
    clk = 1;
    ce = 1;
    rst = 0;
    @(posedge clk);
    rst = 1;
    @(posedge clk);
    rst = 0;
end

integer file_minus_sin, file_cos;

initial
begin
    file_minus_sin = $fopen("file_minus_sin.txt", "w");
    file_cos = $fopen("file_cos.txt", "w");

`ifndef TAYLOR_SERIES_CORRECTION

`ifdef DITHERING_CORRECTION
    repeat(5) @(posedge clk);
`else
    repeat(4) @(posedge clk);
`endif

`else

`ifdef TAYLOR_SERIES_THIRD_TERM
    repeat(7) @(posedge clk);
`else
    repeat(6) @(posedge clk);
`endif

`endif  // `ifndef TAYLOR_SERIES_CORRECTION

    for (int i = 0; i < 16_384; i++)
    begin
        $fwrite(file_minus_sin, "%d\n", minus_sin);
        $fwrite(file_cos, "%d\n", cos);
        @(posedge clk);
    end

    $fclose(file_minus_sin);
    $fclose(file_cos);

    $stop;
end

endmodule: dds_top_tb

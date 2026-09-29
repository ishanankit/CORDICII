`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// CORDIC-II Stage 2 (Kernel 64 + j1) - shift/add only
//////////////////////////////////////////////////////////////////////////////////

module cordic2_stage (
    input  wire signed [31:0] x,
    input  wire signed [31:0] y,
    input  wire signed [31:0] z,  // angle in degrees, Q8.23
    input  wire        clk,
    input  wire        areset,
    output reg  signed [31:0] x1,
    output reg  signed [31:0] y1,
    output reg  signed [31:0] z1
);
    // atan(1/128) = 0.895°, Q8.23
    localparam signed [31:0] ANGLE_0 = 32'sh00728F60;
    localparam signed [31:0] NEG_ANGLE_0 = ~ANGLE_0 + 32'sd1;

    reg signed [47:0] sx, sy;
    reg signed [47:0] tmpx, tmpy;
    reg signed [47:0] divx, divy;

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            x1 <= 32'sd0;
            y1 <= 32'sd0;
            z1 <= 32'sd0;
        end else begin
            sx = { {16{x[31]}}, x };
            sy = { {16{y[31]}}, y };

            tmpx = 48'sd0;
            tmpy = 48'sd0;

            if (z >= 32'sd0) begin
                tmpx = (sx << 6) + ( ~ sy + 48'sd1 ); // 64*x - y
                tmpy = (sy << 6) + sx;                // 64*y + x
                z1   <= z + NEG_ANGLE_0;              // z - ANGLE_0
            end else begin
                tmpx = (sx << 6) + sy;                // 64*x + y
                tmpy = (sy << 6) + ( ~ sx + 48'sd1 ); // 64*y - x
                z1   <= z + ANGLE_0;
            end

            divx = tmpx >> 6;
            divy = tmpy >> 6;

            x1 <= divx[31:0];
            y1 <= divy[31:0];
        end
    end
endmodule

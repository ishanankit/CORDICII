`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// CORDIC-II Stage 1 (Kernel 32 + j1) - shift/add only
//////////////////////////////////////////////////////////////////////////////////

module cordic1_stage (
    input  wire signed [31:0] x,
    input  wire signed [31:0] y,
    input  wire signed [31:0] z,  // angle in degrees, Q8.23
    input  wire        clk,
    input  wire        areset,
    output reg  signed [31:0] x1,
    output reg  signed [31:0] y1,
    output reg  signed [31:0] z1
);
    // atan(1/32) = 1.789°, Q8.23
    localparam signed [31:0] ANGLE_1 = 32'sh00E51EB8;
    localparam signed [31:0] NEG_ANGLE_1 = ~ANGLE_1 + 32'sd1;

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
                // tmpx = (32*x) - y  -> (x<<5) + two's-comp(y)
                tmpx = (sx << 5) + ( ~ sy + 48'sd1 );
                tmpy = (sy << 5) + sx;
                z1   <= z + NEG_ANGLE_1; // z - ANGLE_1
            end else begin
                tmpx = (sx << 5) + sy;
                tmpy = (sy << 5) + ( ~ sx + 48'sd1 );
                z1   <= z + ANGLE_1;
            end

            divx = tmpx >> 5;
            divy = tmpy >> 5;

            x1 <= divx[31:0];
            y1 <= divy[31:0];
        end
    end
endmodule

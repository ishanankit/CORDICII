`timescale 1ns / 1ps

module top(
    input  wire signed [31:0] x,
    input  wire signed [31:0] y,
    input  wire signed [31:0] z,
    input  wire clk,
    output wire signed [31:0] x1,
    output wire signed [31:0] y1,
    output wire signed [31:0] z1
);

    ///////////////////////////////////////////////////////////
    // INTERNAL ONE-CLOCK RESET
    ///////////////////////////////////////////////////////////
    reg init_reset = 1;
    reg reset_done = 0;

    always @(posedge clk) begin
        if (!reset_done) begin
            init_reset <= 1;       // assert reset
            reset_done <= 1;       // mark that reset has occurred
        end else begin
            init_reset <= 0;       // remove reset forever after
        end
    end

    ///////////////////////////////////////////////////////////
    // PIPELINE WIRES
    ///////////////////////////////////////////////////////////
    wire signed [31:0] xt, yt, zt;
    wire signed [31:0] xf, yf, zf;
    wire signed [31:0] xu, yu, zu;
    wire signed [31:0] xc1, yc1, zc1;
    wire signed [31:0] xc2, yc2, zc2;

    ///////////////////////////////////////////////////////////
    // STAGES
    ///////////////////////////////////////////////////////////

    trivial_stage t1 (
        .x(x), .y(y), .z(z),
        .clk(clk), 
        .areset(init_reset),
        .x1(xt), .y1(yt), .z1(zt)
    );

    friend_stage f1 (
        .x(xt), .y(yt), .z(zt),
        .clk(clk), 
        .areset(init_reset),
        .x1(xf), .y1(yf), .z1(zf)
    );

    usr_stage u1 (
        .x(xf), .y(yf), .z(zf),
        .clk(clk), 
        .areset(init_reset),
        .x1(xu), .y1(yu), .z1(zu)
    );

    cordic1_stage c1 (
        .x(xu), .y(yu), .z(zu),
        .clk(clk), 
        .areset(init_reset),
        .x1(xc1), .y1(yc1), .z1(zc1)
    );

    cordic2_stage c2 (
        .x(xc1), .y(yc1), .z(zc1),
        .clk(clk), 
        .areset(init_reset),
        .x1(xc2), .y1(yc2), .z1(zc2)
    );

    nano_stage n1 (
        .x(xc2), .y(yc2), .z(zc2),
        .clk(clk), 
        .areset(init_reset),
        .x1(x1), .y1(y1), .z1(z1)
    );

endmodule

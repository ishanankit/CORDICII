`timescale 1ns / 1ps
module friend_stage (
    input  wire signed [31:0] x,
    input  wire signed [31:0] y,
    input  wire signed [31:0] z,  // angle in degrees, Q8.23
    input  wire        clk,
    input  wire        areset,
    output reg  signed [31:0] x1,
    output reg  signed [31:0] y1,
    output reg  signed [31:0] z1
);
    // Degree constants in Q8.23
    localparam signed [31:0] ANGLE_MID  = 32'sh0D485399; // 26.565°
    localparam signed [31:0] ANGLE_LOW  = 32'sh05270A40; // 10.305°
    localparam signed [31:0] ANGLE_16   = 32'sh08214E68; // 16.26°
    localparam signed [31:0] ANGLE_36   = 32'sh126F58CE; // 36.87°

    // negatives for addition-only operations
    localparam signed [31:0] NEG_ANGLE_LOW = ~ANGLE_LOW + 32'sd1;
    localparam signed [31:0] NEG_ANGLE_16  = ~ANGLE_16 + 32'sd1;
    localparam signed [31:0] NEG_ANGLE_36  = ~ANGLE_36 + 32'sd1;

    // widen temporaries to avoid overflow during shifts/adds
    reg signed [47:0] sx, sy;
    reg signed [47:0] tmpx, tmpy;
    reg signed [47:0] divx, divy;

    // div25 using full-precision reciprocal multiply (shift-add)
    // M = 171,798,691 = sum of shifts at positions:
    // 27,25,22,20,18,15,12,9,4,1,0
    function automatic signed [47:0] div25;
        input signed [47:0] val;
        reg   signed [63:0] prod;
        begin
            prod = (val << 27)
                 + (val << 25)
                 + (val << 22)
                 + (val << 20)
                 + (val << 18)
                 + (val << 15)
                 + (val << 12)
                 + (val << 9)
                 + (val << 4)
                 + (val << 1)
                 + (val << 0);
            div25 = prod >> 32; // arithmetic shift (prod is signed)
        end
    endfunction

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            x1 <= 32'sd0;
            y1 <= 32'sd0;
            z1 <= 32'sd0;
        end else begin
            // sign-extend inputs to 48 bits
            sx = { {16{x[31]}}, x };
            sy = { {16{y[31]}}, y };

            tmpx = 48'sd0;
            tmpy = 48'sd0;

            // Case 1: z in [-10.305°, +10.305°]
            if (z <= ANGLE_LOW && z >= NEG_ANGLE_LOW) begin
                // tmpx = x*25 = (x<<4)+(x<<3)+x
                tmpx = (sx << 4) + (sx << 3) + sx;
                tmpy = (sy << 4) + (sy << 3) + sy;
                z1   <= z;
            end
            // Case 2: (10.305, 26.565] CCW
            else if (z > ANGLE_LOW && z <= ANGLE_MID) begin
                // tmpx = 24*x - 7*y -> 24*x + two's-comp(7*y)
                tmpx = (sx << 4) + (sx << 3)
                     + ( ~ ( (sy << 2) + (sy << 1) + sy ) + 48'sd1 );
                tmpy = ( (sx << 2) + (sx << 1) + sx ) + ( (sy << 4) + (sy << 3) );
                z1   <= z + NEG_ANGLE_16; // z - ANGLE_16
            end
            // Case 3: (-26.565, -10.305) CW
            else if (z < NEG_ANGLE_LOW && z >= (~ANGLE_MID + 32'sd1)) begin
                tmpx = (sx << 4) + (sx << 3) + ( (sy << 2) + (sy << 1) + sy );
                tmpy = ( ~ ( (sx << 2) + (sx << 1) + sx ) + 48'sd1 ) + ( (sy << 4) + (sy << 3) );
                z1   <= z + ANGLE_16;
            end
            // Case 4: (26.565, 45] CCW
            else if (z > ANGLE_MID) begin
                tmpx = ( (sx << 4) + (sx << 2) ) + ( ~ ( (sy << 3) + (sy << 2) + (sy << 1) + sy ) + 48'sd1 );
                tmpy = ( (sx << 3) + (sx << 2) + (sx << 1) + sx ) + ( (sy << 4) + (sy << 2) );
                z1   <= z + NEG_ANGLE_36; // z - ANGLE_36
            end
            // Case 5: [-45, -26.565) CW
            else begin
                tmpx = ( (sx << 4) + (sx << 2) ) + ( (sy << 3) + (sy << 2) + (sy << 1) + sy );
                tmpy = ( ~ ( (sx << 3) + (sx << 2) + (sx << 1) + sx ) + 48'sd1 ) + ( (sy << 4) + (sy << 2) );
                z1   <= z + ANGLE_36;
            end

            // divide-by-25 using shift-add reciprocal
            divx = div25(tmpx);
            divy = div25(tmpy);

            x1 <= divx[31:0];
            y1 <= divy[31:0];
        end
    end
endmodule

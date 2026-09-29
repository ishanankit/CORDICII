`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Trivial Stage - Quadrant Normalization (Corrected for CCW rotation)
//////////////////////////////////////////////////////////////////////////////////

module trivial_stage (
    input  wire signed [31:0] x,
    input  wire signed [31:0] y,
    input  wire signed [31:0] z,  // angle in degrees, Q8.23
    input  wire clk,
    input  wire areset,
    output reg  signed [31:0] x1,
    output reg  signed [31:0] y1,
    output reg  signed [31:0] z1
);

    // Degree constants in Q8.23
    localparam signed [31:0] ANGLE_45  = 32'sh16800000;
    localparam signed [31:0] ANGLE_90  = 32'sh2d000000;
    localparam signed [31:0] ANGLE_135 = 32'sh43800000;
    localparam signed [31:0] ANGLE_180 = 32'sh5a000000;

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            x1 <= 0;
            y1 <= 0;
            z1 <= 0;
        end else begin
            // Case 1: z in [-45°, +45°]
            if (z <= ANGLE_45 && z >= -ANGLE_45) begin
                x1 <= x;
                y1 <= y;
                z1 <= z;
            end
            // Case 2: z in (45°, 135°] → Rotate -90° (CCW correction)
            else if (z > ANGLE_45 && z <= ANGLE_135) begin
                x1 <= -y;
                y1 <=  x;
                z1 <= z - ANGLE_90;
            end
            // Case 3: z in (-135°, -45°) → Rotate +90° (CW correction)
            else if (z < -ANGLE_45 && z >= -ANGLE_135) begin
                x1 <=  y;
                y1 <= -x;
                z1 <= z + ANGLE_90;
            end
            // Case 4: z in (135°, 180°] or (-180°, -135°)
            else begin
                x1 <= -x;
                y1 <= -y;
                if (z > 0)
                    z1 <= z - ANGLE_180;
                else
                    z1 <= z + ANGLE_180;
            end
        end
    end
endmodule

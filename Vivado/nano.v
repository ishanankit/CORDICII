`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Nano CORDIC Stage - shift-only add-only (k = 1..8)
// Auto-k selection and angle_k computed with shift-add
//////////////////////////////////////////////////////////////////////////////////

module nano_stage (
    input  wire signed [31:0] x,
    input  wire signed [31:0] y,
    input  wire signed [31:0] z,   // input angle, Q8.23
    input  wire        clk,
    input  wire        areset,
    output reg  signed [31:0] x1,
    output reg  signed [31:0] y1,
    output reg  signed [31:0] z1
);

    // Base angle atan(1/512) = ~0.11186°, Q8.23
    localparam signed [31:0] ANGLE_BASE = 32'sh0016E000;

    // Thresholds
    localparam signed [31:0] ANG_THR0 = 32'sh0016E000; // 0.11186°
    localparam signed [31:0] ANG_THR1 = 32'sh002DC000; // 0.2237°
    localparam signed [31:0] ANG_THR2 = 32'sh00442000; // 0.3355°
    localparam signed [31:0] ANG_THR3 = 32'sh005AE000; // 0.4472°
    localparam signed [31:0] ANG_THR4 = 32'sh0071A000; // 0.5590°
    localparam signed [31:0] ANG_THR5 = 32'sh00888000; // 0.6707°
    localparam signed [31:0] ANG_THR6 = 32'sh009F2000; // 0.7823°
    localparam signed [31:0] ANG_THR7 = 32'sh00B60000; // 0.8940°

    // temporaries (module scope)
    reg signed [47:0] sx, sy;
    reg signed [47:0] tmpx, tmpy;
    reg signed [47:0] divx, divy;

    reg signed [31:0] absz;
    reg [3:0] k_val;
    reg signed [31:0] angle_k; // Q8.23

    // module-scope registers used in sequential block
    reg signed [47:0] kx;
    reg signed [47:0] ky;
    reg signed [47:0] X512;
    reg signed [47:0] Y512;

    // helper: multiply small signed 32-bit by k (1..8) via shift-add
    function signed [47:0] mul_k_48;
        input signed [31:0] val;
        input [3:0] k;
        reg signed [47:0] r;
        reg signed [47:0] v48;
        begin
            v48 = { {16{val[31]}}, val };
            r = 48'sd0;
            if (k[0]) r = r + v48;        // +1
            if (k[1]) r = r + (v48 << 1); // +2
            if (k[2]) r = r + (v48 << 2); // +4
            if (k[3]) r = r + (v48 << 3); // +8
            mul_k_48 = r;
        end
    endfunction

    // helper: multiply ANGLE_BASE by small k (1..8) using shift-add (angle_k in Q8.23)
    function signed [31:0] mul_k_angle;
        input signed [31:0] base;
        input [3:0] k;
        reg signed [47:0] r;
        reg signed [47:0] b48;
        begin
            b48 = { {16{base[31]}}, base };
            r = 48'sd0;
            if (k[0]) r = r + b48;
            if (k[1]) r = r + (b48 << 1);
            if (k[2]) r = r + (b48 << 2);
            if (k[3]) r = r + (b48 << 3);
            // result fit back to 32-bit Q8.23 (k<=8 so safe)
            mul_k_angle = r[31:0];
        end
    endfunction

    // combinational block for k selection and angle_k
    always @(*) begin
        // absolute of z (two's complement)
        if (z[31]) absz = (~z) + 32'sd1;
        else       absz = z;

        if (absz <= ANG_THR0)      k_val = 4'd1;
        else if (absz <= ANG_THR1) k_val = 4'd2;
        else if (absz <= ANG_THR2) k_val = 4'd3;
        else if (absz <= ANG_THR3) k_val = 4'd4;
        else if (absz <= ANG_THR4) k_val = 4'd5;
        else if (absz <= ANG_THR5) k_val = 4'd6;
        else if (absz <= ANG_THR6) k_val = 4'd7;
        else                       k_val = 4'd8;

        angle_k = mul_k_angle(ANGLE_BASE, k_val);
    end

    always @(posedge clk or posedge areset) begin
        if (areset) begin
            x1 <= 32'sd0;
            y1 <= 32'sd0;
            z1 <= 32'sd0;
            // clear temps
            sx <= 48'sd0;
            sy <= 48'sd0;
            tmpx <= 48'sd0;
            tmpy <= 48'sd0;
            divx <= 48'sd0;
            divy <= 48'sd0;
            kx <= 48'sd0;
            ky <= 48'sd0;
            X512 <= 48'sd0;
            Y512 <= 48'sd0;
        end else begin
            // sign-extend inputs to 48 bits
            sx = { {16{x[31]}}, x };
            sy = { {16{y[31]}}, y };

            // precompute k*x and k*y
            kx = mul_k_48(x, k_val);
            ky = mul_k_48(y, k_val);

            // X512 and Y512 (512*x = x<<9)
            X512 = sx << 9;
            Y512 = sy << 9;

            if (z >= 32'sd0) begin
                tmpx = X512 + ( ~ky + 48'sd1 ); // 512*x - k*y
                tmpy = Y512 + kx;               // 512*y + k*x
                // z - angle_k  => z + (~angle_k + 1)
                z1   <= z + ( ~angle_k + 32'sd1 );
            end else begin
                tmpx = X512 + ky;               // 512*x + k*y
                tmpy = Y512 + ( ~kx + 48'sd1 ); // 512*y - k*x
                z1   <= z + angle_k;
            end

            // normalize by 512 => arithmetic right shift by 9
            divx = tmpx >> 9;
            divy = tmpy >> 9;

            x1 <= divx[31:0];
            y1 <= divy[31:0];
        end
    end
endmodule

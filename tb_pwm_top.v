`timescale 1ns/1ps
module tb_pwm_top;
    reg clk;
    reg rst;
    reg btn_mode;
    reg btn_step;
    reg man_wr;
    reg [1:0] man_ch;
    reg [7:0] man_val;

    wire pwm0, pwm1, pwm2;
    wire [7:0] count_out;
    wire [7:0] d0, d1, d2;

    pwm_top dut (
        .clk(clk), .rst(rst),
        .btn_mode(btn_mode), .btn_step(btn_step),
        .man_wr(man_wr), .man_ch(man_ch), .man_val(man_val),
        .pwm0(pwm0), .pwm1(pwm1), .pwm2(pwm2),
        .count_out(count_out),
        .d0(d0), .d1(d1), .d2(d2)
    );

    // Clock 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        rst = 1;
        btn_mode = 0;
        btn_step = 0;
        man_wr = 0;
        man_ch = 0;
        man_val = 0;

        #50 rst = 0;

        // Ubah duty CH0 ? 25%
        #100;
        man_ch = 0;
        man_val = 8'd64;
        man_wr = 1;
        #10 man_wr = 0;

        // Ubah duty CH1 ? 75%
        #200;
        man_ch = 1;
        man_val = 8'd192;
        man_wr = 1;
        #10 man_wr = 0;

        #1000;
 
    end
endmodule


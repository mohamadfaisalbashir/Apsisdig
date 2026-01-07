module pwm_top (
    input  wire clk,
    input  wire rst,

    input  wire btn_mode,
    input  wire btn_step,
    input  wire man_wr,
    input  wire [1:0] man_ch,
    input  wire [7:0] man_val,

    output wire pwm0,
    output wire pwm1,
    output wire pwm2,

    output wire [7:0] count_out,
    output wire [7:0] d0,
    output wire [7:0] d1,
    output wire [7:0] d2
);

    // =================================================
    // CLOCK DIVIDER (diperkecil biar waveform kelihatan)
    // =================================================
    wire pwm_clk;
    clock_divider #(.DIV(4)) u_div (
        .clk_in(clk),
        .rst(rst),
        .clk_out(pwm_clk)
    );

    // =================
    // PWM COUNTER
    // =================
    wire [7:0] count;
    counter_pwm u_cnt (
        .clk(pwm_clk),
        .rst(rst),
        .count(count)
    );

    assign count_out = count;

    // =================
    // CONTROLLER
    // =================
    wire we;
    wire [1:0] ch_sel;
    wire [7:0] duty_in;

    controller u_ctrl (
        .clk(clk),
        .rst(rst),
        .btn_mode(btn_mode),
        .btn_step(btn_step),
        .man_wr(man_wr),
        .man_ch(man_ch),
        .man_val(man_val),
        .we(we),
        .ch_sel(ch_sel),
        .duty_in(duty_in)
    );

    // =================
    // DUTY REGISTERS
    // =================
    wire [7:0] duty0, duty1, duty2;

    duty_register u_duty (
        .clk(clk),
        .rst(rst),
        .we(we),
        .ch_sel(ch_sel),
        .duty_in(duty_in),
        .duty0(duty0),
        .duty1(duty1),
        .duty2(duty2)
    );

    assign d0 = duty0;
    assign d1 = duty1;
    assign d2 = duty2;

    // =================
    // PWM GENERATORS (INI KUNCI)
    // =================
    pwm_generator pwm_gen0 (
        .clk(pwm_clk),
        .rst(rst),
        .duty(duty0),
        .count(count),
        .pwm(pwm0)
    );

    pwm_generator pwm_gen1 (
        .clk(pwm_clk),
        .rst(rst),
        .duty(duty1),
        .count(count),
        .pwm(pwm1)
    );

    pwm_generator pwm_gen2 (
        .clk(pwm_clk),
        .rst(rst),
        .duty(duty2),
        .count(count),
        .pwm(pwm2)
    );

endmodule


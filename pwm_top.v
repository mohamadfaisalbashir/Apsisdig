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

// controller.v
module controller (
    input  wire clk,
    input  wire rst,
    input  wire btn_mode,     // toggle mode (manual/auto) -- edge sensitive in TB
    input  wire btn_step,     // in manual mode: step channel / increment duty
    // manual write interface
    input  wire [1:0] man_ch,
    input  wire [7:0] man_val,
    input  wire man_wr,       // pulse to write manual value
    // outputs to duty_register
    output reg        we,
    output reg  [1:0] ch_sel,
    output reg  [7:0] duty_in
);
    reg mode_auto; // 1 = auto, 0 = manual

    // simple debounce/edge detect omitted for brevity; in TB we present pulses
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            mode_auto <= 1'b1;
            we <= 0;
            ch_sel <= 2'd0;
            duty_in <= 8'd0;
        end else begin
            we <= 0;
            if (btn_mode) mode_auto <= ~mode_auto;

            if (mode_auto) begin
                // simple rotating pattern: increment each channel every N cycles
                // For simplicity controller doesn't autoupdate here; TB will stimulate manual writes
                // (We keep auto simple: write preset sequence when btn_step used)
                if (btn_step) begin
                    // rotate through channels and increase duty by 32
                    ch_sel <= ch_sel + 1;
                    duty_in <= duty_in + 8'd32;
                    we <= 1;
                end
            end else begin
                // manual write: if man_wr pulse, write provided value
                if (man_wr) begin
                    we <= 1;
                    ch_sel <= man_ch;
                    duty_in <= man_val;
                end
            end
        end
    end
endmodule

module clock_divider #(
    parameter DIV = 2   // <<<<<< PENTING: kecilkan
)(
    input  wire clk_in,
    input  wire rst,
    output reg  clk_out
);

reg [1:0] cnt;

always @(posedge clk_in or posedge rst) begin
    if (rst) begin
        cnt <= 0;
        clk_out <= 0;
    end else begin
        if (cnt == DIV-1) begin
            cnt <= 0;
            clk_out <= ~clk_out;
        end else begin
            cnt <= cnt + 1;
        end
    end
end

endmodule

// counter_pwm.v
module counter_pwm (
    input  wire clk,
    input  wire rst,
    output reg  [7:0] count
);
    always @(posedge clk or posedge rst) begin
    if (rst)
        count <= 0;
    else
        count <= count + 1;
end

endmodule

// duty_register.v
module duty_register (
    input  wire         clk,
    input  wire         rst,
    // write interface
    input  wire         we,         // write enable
    input  wire [1:0]   ch_sel,     // channel select 0..2
    input  wire [7:0]   duty_in,
    // outputs
    output reg  [7:0]   duty0,
    output reg  [7:0]   duty1,
    output reg  [7:0]   duty2
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            duty0 <= 8'd64;   // default ~25%
            duty1 <= 8'd128;  // default 50%
            duty2 <= 8'd192;  // default 75%
        end else if (we) begin
            case (ch_sel)
                2'd0: duty0 <= duty_in;
                2'd1: duty1 <= duty_in;
                2'd2: duty2 <= duty_in;
                default: ;
            endcase
        end
    end
endmodule

module pwm_generator (
    input  wire clk,
    input  wire rst,
    input  wire [7:0] count,
    input  wire [7:0] duty,
    output reg  pwm
);

always @(posedge clk or posedge rst) begin
    if (rst)
        pwm <= 1'b0;
    else
        pwm <= (count < duty);
end

endmodule
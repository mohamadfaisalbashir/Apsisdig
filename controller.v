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


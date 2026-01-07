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


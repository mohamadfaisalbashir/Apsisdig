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


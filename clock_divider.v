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


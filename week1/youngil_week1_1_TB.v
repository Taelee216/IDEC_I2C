module I2C_Master_TB;

reg rst;
reg clk;
reg sel;
wire [3:0] state; 

I2C_Master u0 (.rst(rst), .clk(clk), .sel(sel), .state(state));

initial begin
	clk = 1'b0;
	forever #5 clk = ~clk;
end

initial begin
rst = 1'b0;
#3
rst = 1'b1;
end

initial begin
#5
sel = 1'b1;
end

endmodule

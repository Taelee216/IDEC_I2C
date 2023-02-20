module I2C_Master_TB;

reg [7:0] Data_in;
reg [7:0] Reg_addr;
reg [6:0] Dev_addr;
reg	   clk,rst,RW_sel;

reg	 SDA_in;
wire	 SDA_out;
wire	 SCL_out;

I2C_Master u0 (.Data_in(Data_in), .Reg_addr(Reg_addr), .Dev_addr(Dev_addr), .clk(clk), .rst(rst), .RW_sel(RW_sel), .SDA_in(SDA_in), .SDA_out(SDA_out), .SCL_out(SCL_out));

initial begin
	clk = 1'b0;
	forever #1 clk = ~clk;
end

initial begin
rst = 1'b0;
#9
rst = 1'b1;
end

initial begin
Dev_addr <= 7'b1010101;
RW_sel <= 1'b1;
Data_in <=  8'b01010101;
SDA_in <= 1'b0;
Reg_addr <= 8'b11010101;
end

endmodule

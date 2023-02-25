module I2C_Master_TB;

reg [7:0] _Data_in;
reg [7:0] _Reg_addr;
reg [6:0] _Dev_addr;
reg	   	  clk,rst,_RW_sel;

reg	 	 SDA_in;
wire	 SDA_out;
wire	 SCL_out;

I2C_Master u1 (._Data_in(_Data_in), ._Reg_addr(_Reg_addr), ._Dev_addr(_Dev_addr), .clk(clk), .rst(rst), ._RW_sel(_RW_sel), .SDA_in(SDA_in), .SDA_out(SDA_out), .SCL_out(SCL_out));

initial begin
	clk = 1'b0;
	forever #1 clk = ~clk;
end
								//__________able to change__________//
initial begin
rst = 1'b0;
#9
rst = 1'b1;
end

initial begin 
_Dev_addr <= 7'b1010101;
_RW_sel <= 1'b0;
_Data_in <=  8'b01010101;
SDA_in <= 1'b0;
_Reg_addr <= 8'b10100101;
end

endmodule
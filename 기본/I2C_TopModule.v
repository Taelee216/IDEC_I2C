module I2C_TopModule;

reg [7:0] _Data_in;
reg [7:0] _Reg_addr;
reg [6:0] _Dev_addr;
reg	   clk,rst,_RW_sel;

wire	 _SDA_in;
wire	 SDA_out;
wire	 SCL_out;

I2C_Master Master (._Data_in(_Data_in), ._Reg_addr(_Reg_addr), ._Dev_addr(_Dev_addr), .clk(clk), .rst(rst), ._RW_sel(_RW_sel), ._SDA_in(_SDA_in), .SDA_out(SDA_out), .SCL_out(SCL_out));
I2C_EEPROM EEPROM (.SDA_out(SDA_out), .SCL(SCL), .rst(rst), .SDA_in(_SDA_in));

endmodule
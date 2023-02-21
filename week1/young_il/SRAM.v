module SRAM #(

parameter ADDR   = 8,
parameter DATA   = 8,
parameter DEPTH  = 256
              )

(
input	wire	[DATA-1:0]	dataIn,
output	reg	[DATA-1:0]	dataOut,
input	wire	[ADDR-1:0]	Addr,
input	wire			rst, RW, clk

);

reg [DATA-1:0] SRAM [DEPTH-1:0];

always @ (posedge clk) begin
	if (rst) begin
		if (!RW) begin	//Write
			SRAM [Addr] = dataIn;
		end
		
		else	 begin	//Read
			dataOut = SRAM [Addr]; 
		end
	end
	else	 begin
		SRAM [Addr] = 0;
		dataOut =0;
	end
end

endmodule
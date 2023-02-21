module SRAM_TB#(

parameter ADDR   = 8,
parameter DATA   = 8,
parameter DEPTH  = 256
              );

reg  [DATA-1:0]	dataIn;
wire [DATA-1:0]	dataOut;
reg  [ADDR-1:0]	Addr;
reg 		rst, RW, clk;

SRAM u0 (.dataIn(dataIn), .dataOut(dataOut), .Addr(Addr), .rst(rst), .RW(RW), .clk(clk));

reg [7:0] i = 0;

initial
begin
	clk = 0;
	forever #1 clk = ~clk;
end

initial
begin
	rst = 0;
#5
	rst = 1;
end


always @ (posedge clk) begin
#6
RW <= 0;
Addr <= 8'd0;
dataIn <= 8'd0;
#5
Addr <= 8'd1;
dataIn <= 8'd1;
#5
Addr <= 8'd2;
dataIn <= 8'd2;
#5
Addr <= 8'd3;
dataIn <= 8'd3;

#5
Addr <= 8'd4;
dataIn <= 8'd4;
#5
Addr <= 8'd5;
dataIn <= 8'd5;
#5
Addr <= 8'd6;
dataIn <= 8'd6;

#10
RW<=1;
dataIn<=0;
Addr <= 8'd0;
#5
Addr <= 8'd1;
#5
Addr <= 8'd2;
#5
Addr <= 8'd3;
#5
Addr <= 8'd4;
#5
Addr <= 8'd5;
#5
Addr <= 8'd6;
end

endmodule
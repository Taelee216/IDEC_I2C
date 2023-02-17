
//ex2 u0 (.nrst(KEY[0]), .clk(MAX10_CLK1_50), .msb_q(LEDR[0]));
//part1_fpga u1(.c1(SW[1]), .c0(SW[0]), .out(HEX0));

//ssdb_shift u2(.rst(SW[0]), .w(SW[1]), .clk(KEY[0]), .z(LEDR[9]));//, .state(LEDR[8:0]));
/*
addr u3(
	.a(SW[7:0]),
	.clk(~KEY[1]),
	.nrst(KEY[0]),
	.carry(LEDR[8]),
	.ov(LEDR[9]),
	.hex1_s(HEX1),
	.hex0_s(HEX0)
);
*/
/*
mul asdf(
    .a(SW[7:0]),
	 .b(SW[7:0]),
    .ena(SW[9]),
    .enb(SW[8]),
    .clk(~KEY[1]),
    .rst(KEY[0]),
    .hex3_m(HEX3),
    .hex2_m(HEX2),
	 .hex1_m(HEX1),
    .hex0_m(HEX0)
);
modulocounter asdff(.en(SW[0]), .clk(KEY[1]), .rst(KEY[0]), .rollover(LEDR[9]), .hexcount1(HEX1), .hexcount0(HEX0));*/
bcdcounter asdfasdfasdf(
    .clk(MAX10_CLK1_50),
    .en(SW[0]),
    .rst(KEY[0]),
    .hex1(HEX0), 
	 .hex2(HEX1), 
	 .hex3(HEX2)
);
endmodule
/////////////////////////////////////////////////////////
module bcdcounter(
    input wire clk,
    input wire en,
    input wire rst,
    output wire [6:0] hex1, hex2, hex3
);
wire [7:0] first, second, last, out1, out2, out3;
reg [24:0] large_cnt;

wire tick_1s = &large_cnt;

always @ (posedge clk, negedge rst) begin
    if(~rst) large_cnt <= 25'b0;
    else large_cnt <= large_cnt + 1'b1;
	 //if(large_cnt >= 25'b1) large_cnt <= 25'b0;
end
modulocounter u0(.en(en), .clk(tick_1s), .rst(rst), .rollover(first), .count(out1));
modulocounter u1(.en(first), .clk(tick_1s), .rst(rst), .rollover(second), .count(out2));
modulocounter u2(.en(second & first), .clk(tick_1s), .rst(rst), .rollover(last), .count(out3));

segdec ua(.i(out1[3:0]), .o(hex1));
segdec ub(.i(out2[3:0]), .o(hex2));
segdec ubc(.i(out3[3:0]), .o(hex3));
endmodule



module modulocounter #
(
    parameter k = 10
)
(
    input wire en,
    input wire clk,
    input wire rst,
    output reg rollover,
    //output wire [6:0] hexcount1,
    //output wire [6:0] hexcount0
    output reg [7:0] count
);

//reg [7:0] count;
always @(posedge clk, negedge rst)
    if(~rst) count <= 8'b0;
    else if (en) begin
        if(count >= k-1) count <= 8'b0;
        else count <= count + 1;
    end
    else count <= count;

always @*
    if(count == (k-1)) rollover <= 1'b1;
    else rollover <= 1'b0;


//segdec ua(.i(count[3:0]), .o(hexcount0));
//segdec ub(.i(count[7:4]), .o(hexcount1));
endmodule

module ex2(
	input wire nrst,
	input clk,
	output wire msb_q
);

reg [25:0] q;

always @(posedge clk)
	if(~nrst) q <= 0;
	else q<= q +1'b1;
	
	assign msb_q = q[25];
	
endmodule

module part1_fpga(
	input wire c1,
	input wire c0,
	output reg [6:0] out
);
	always @(*) begin
		case({c1,c0})
			2'b00: out = 7'b010_0001;
			2'b01: out = 7'b000_0110;
			2'b10: out = 7'b111_1001;
			2'b11: out = 7'b100_0000;
		endcase
	end

endmodule
//same w four time-> z high
module sdb_fsm(
	input wire rst,
	input wire w,
	input wire clk,
	output reg z,
	output reg [8:0] state
);

//parameter [3:0] A = 4'd0, B = 4'd1, C = 4'd2, D = 4'd3, E = 4'd4, F = 4'd5, G = 4'd6;
//parameter [3:0] H = 4'd7, I = 4'd8;

parameter A = 9'b00000_0000;
parameter B = 9'b00000_0011;
parameter C = 9'b00000_0101;
parameter D = 9'b00000_1001;
parameter E = 9'b00001_0001;
parameter F = 9'b00010_0001;
parameter G = 9'b00100_0001;
parameter H = 9'b01000_0000;
parameter I = 9'b10000_0001;

reg [8:0] next;

always @ (posedge clk) 
 if(rst) state <= A;
 else state <= next;
 /*
always @ (state, w) begin
	next = 3'bx; z = 1'b0;
	case ({state, w})
		A: if(w) next = F; else next = B;
		B: if(w) next = F; else next = C;
		C: if(w) next = F; else next = D;
		D: if(w) next = F; else next = E;
		E: if(w) next = F; else {next, z} = {E, 1'b1};
		F: if(w) next = G; else next = B;
		G: if(w) next = H; else next = B;
		H: if(w) next = I; else next = B;
		I: if(w) {next, z} = {I, 1'b1}; else next = B;
	endcase
end
*/
always @*
	case({state, w})
		{A, 1'b0}: {next, z} = {B, 1'b0};
		{A, 1'b1}: {next, z} = {F, 1'b0};
						
		{B, 1'b0}: {next, z} = {C, 1'b0};
		{B, 1'b1}: {next, z} = {F, 1'b0};
										
		{C, 1'b0}: {next, z} = {D, 1'b0};
		{C, 1'b1}: {next, z} = {F, 1'b0};
														
		{D, 1'b0}: {next, z} = {E, 1'b0};
		{D, 1'b1}: {next, z} = {F, 1'b0};
														
		{E, 1'b0}: {next, z} = {E, 1'b1};
		{E, 1'b1}: {next, z} = {F, 1'b1};
														
		{F, 1'b0}: {next, z} = {B, 1'b0};
		{F, 1'b1}: {next, z} = {G, 1'b0};
														
		{G, 1'b0}: {next, z} = {B, 1'b0};
		{G, 1'b1}: {next, z} = {H, 1'b0};
														
		{H, 1'b0}: {next, z} = {B, 1'b0};
		{H, 1'b1}: {next, z} = {I, 1'b0};		
		
		{I, 1'b0}: {next, z} = {B, 1'b1};
		{I, 1'b1}: {next, z} = {I, 1'b1};
		
		default: {next, z} = {A, 1'b0};
	endcase

	reg [31:0] debug_st; // for simulation debugging
	
endmodule	

module ssdb_shift(
	input wire rst,
	input wire w,
	input wire clk,
	output wire z
);

reg [3:0] shift_reg;
wire [3:0] next_shift_reg = {shift_reg[2:0], w};

always @(posedge clk)
	if(rst) shift_reg <= 4'd0;
	else shift_reg <= next_shift_reg;
	
assign z = (&shift_reg) | (~|shift_reg);

endmodule

// Quartus Prime Verilog Template
// Single port RAM with single read/write address 

module single_port_ram 
#(parameter DATA_WIDTH=8, parameter ADDR_WIDTH=6)
(
	input [(DATA_WIDTH-1):0] data,
	input [(ADDR_WIDTH-1):0] addr,
	input we, clk,
	output [(DATA_WIDTH-1):0] q
);

	// Declare the RAM variable
	reg [DATA_WIDTH-1:0] ram[2**ADDR_WIDTH-1:0];

	// Variable to hold the registered read address
	reg [ADDR_WIDTH-1:0] addr_reg;

	always @ (posedge clk)
	begin
		// Write
		if (we)
			ram[addr] <= data;

		addr_reg <= addr;
	end

	// Continuous assignment implies read returns NEW data.
	// This is the natural behavior of the TriMatrix memory
	// blocks in Single Port mode.  
	assign q = ram[addr_reg];

endmodule


module addr(
	input wire [7:0] a,
	input wire clk,
	input wire nrst,
	output reg carry,
	output reg ov,
	output wire [6:0] hex1_s,
	output wire [6:0] hex0_s
);

reg [7:0] a_;
reg [7:0] s_;
wire [8:0] s;
reg ov_;

always @(posedge clk, negedge nrst)
	if(~nrst) a_ <= 8'b0;
	else a_ <= a;

assign s = a_ + s_; //8bit + 8bit -> 9bit

always @(posedge clk, negedge nrst)
	if(~nrst) carry <= 1'b0;
	else carry <= s[8];
	
always @ (posedge clk, negedge nrst)
	if(~nrst) s_ <= 8'd0;
	else s_ <= s[7:0];
	
always @*
	case({a_[7], s_[7], s[7]})
		3'b110, 3'b001: ov_ <=1'b0;
		default ov_ <= 1'b0;
	
	endcase

always @(posedge clk, negedge nrst)
	if(~nrst) ov <= 1'b0;
	else ov <= ov_;

segdec u0(.i(s_[3:0]), .o(hex0_s));
segdec u1(.i(s_[7:4]), .o(hex1_s));
	
endmodule 


module segdec(
     input [3:0] i,
     output reg [6:0] o
);
     
always @*
    case (i)
        4'h1: o = 7'b1111001;	// ---t----
        4'h2: o = 7'b0100100; 	// |	  |
        4'h3: o = 7'b0110000; 	// lt	 rt
        4'h4: o = 7'b0011001; 	// |	  |
        4'h5: o = 7'b0010010; 	// ---m----
        4'h6: o = 7'b0000010; 	// |	  |
        4'h7: o = 7'b1111000; 	// lb	 rb
        4'h8: o = 7'b0000000; 	// |	  |
        4'h9: o = 7'b0011000; 	// ---b----
        4'ha: o = 7'b0001000;
        4'hb: o = 7'b0000011;
        4'hc: o = 7'b1000110;
        4'hd: o = 7'b0100001;
        4'he: o = 7'b0000110;
        4'hf: o = 7'b0001110;
        4'h0: o = 7'b1000000;
    endcase
    
endmodule



module mul(
    input wire [7:0] a,
	 input wire [7:0] b,
    input wire ena,
    input wire enb,
    input wire clk,
    input wire rst,
    output wire [6:0] hex1_m,
    output wire [6:0] hex0_m,
	output wire [6:0] hex2_m,
    output wire [6:0] hex3_m
);

reg [7:0] a_, b_;
reg [15:0] p;
wire [15:0] mul;


always @ (posedge clk)
    if(rst & !ena) a_ <= 8'b0; 
    else a_ <= a;

always @ (posedge clk)
    if(rst & !enb) b_ <= 8'b0; 
    else b_ <= b;

always @ (posedge clk)
    if(rst) p <= 8'b0; 
    else p <= a_*b_;



segdec u23(.i(p[3:0]), .o(hex0_m));
segdec u24(.i(p[7:4]), .o(hex1_m));
segdec u012(.i(p[11:8]), .o(hex2_m));
segdec u112(.i(p[15:12]), .o(hex3_m));

endmodule
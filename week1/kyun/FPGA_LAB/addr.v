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
	input wire [3:0] i,
	output reg [6:0] o
	);

always @*
	case(i)
		4'b0000: o = 7'b1000000;
		4'b0001: o = 7'b1111001;
		4'b0010: o = 7'b0100100;
		4'b0011: o = 7'b0110000;
		4'b0100: o = 7'b0011001;
		4'b0101: o = 7'b0010010;
		4'b0110: o = 7'b0000010;
		4'b0111: o = 7'b1011000;
		4'b1000: o = 7'b0000000;
		4'b1001: o = 7'b0010000;
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
wire [15:0] mul;

always @ (posedge clk)
    if(rst & !ena) a_ <= 8'b0; 
    else a_ <= a;

always @ (posedge clk)
    if(rst & !enb) b_ <= 8'b0; 
    else b_ <= a;

assign mul = a_* b_;

segdec u23(.i(mul[3:0]), .o(hex0_m));
segdec u24(.i(mul[7:4]), .o(hex1_m));
segdec u012(.i(mul[11:8]), .o(hex2_m));
segdec u112(.i(mul[15:12]), .o(hex3_m));

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
        if(count > k-1) count <= 8'b0;
        else count <= count + 1;
    end
    else count <= count;

always @*
    if(count == (k-1)) rollover <= 1'b1;
    else rollover <= 1'b0;


//segdec ua(.i(count[3:0]), .o(hexcount0));
//segdec ub(.i(count[7:4]), .o(hexcount1));
endmodule

module bcdcounter(
    input wire clk,
    input wire en,
    input wire rst,
    output wire [6:0] hex1, hex2, hex3
);
wire [7:0] first, second, last, out1, out2, out3;
reg [25:0] large_cnt;

wire tick_1s = &large_cnt;
always @ (posedge clk, negedge rst)
    if(~rst) large_cnt <= 26'b0;
    else large_cnt <= large_cnt + 1'b1;
modulocounter u0(.en(en), .clk(tick_1s), .rst(rst), .rollover(first), .count(out1));
modulocounter u1(.en(first), .clk(tick_1s), .rst(rst), .rollover(second), .count(out2));
modulocounter u2(.en(second & first), .clk(tick_1s), .rst(rst), .rollover(last), .count(out3));

segdec ua(.i(out1[3:0]), .o(hex0));
segdec ub(.i(out2[3:0]), .o(hex1));
segdec ubasdf(.i(out3[3:0]), .o(hex2));
endmodule

module rtclk(
    input wire clk,
    output wire [6:0] hex5,
    output wire [6:0] hex4,
    output wire [6:0] hex3,
    output wire [6:0] hex2,
    output wire [6:0] hex1,
    output wire [6:0] hex0,
);

wire min;
wire sec;
wire msec;
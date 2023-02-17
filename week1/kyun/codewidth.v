module test();
reg [2:0] a;
reg [3:0] b;
reg [7:0] c;

initial begin
    a = 3'd4;
    b = 4'd3;
    $display("%b", a**b);
    c = a**b;
    $display("%b",c);
    c = {a**b};
    $display("%b",c);    
end
endmodule

module adder #(
    parameter N=8
)(
    input wire [N-1:0] a,b,
    input wire cin,
    output wire [N-1:0] sum,
    output wire cout
);

assign {cout, sum} = a + b + cin;

endmodule
//adder #param #inst name --order

module mux(
    input wire a,
    input wire b,
    input wire sel,
    output wire o
);

assign o = sel ? a :b;
endmodule
module mux_n #(
    parameter N = 8
)(
    input wire [N-1:0] a
);
assign o = sel? b :a;
genvar I;
generate
    for(i=0; i<N;i=i+1) begin: gen_blk
        mux u0();
    end
endgenerate
endmodule
/*
module I2C_Master (
    input wire clk,
    input wire nrst,
    input wire s_bit,
    input wire RW_SEL,
    input wire ack,
    
    input wire [6:0] Device_Addr,
    input wire [7:0] Data_in,
    output reg [7:0] Data_out,

    output reg SCL,
    input wire SDA_in,
    output reg SDA_out

);
*/

module I2C_Masert_tb;

reg clk, nrst, s_bit;
wire SCL, SDA_out;

I2C_Master u0(.clk(clk), .nrst(nrst), .s_bit(s_bit), .SCL(SCL), .SDA_out(SDA_out));

initial begin
    clk = 1'b0;
    forever #5 clk = ~clk;
end

initial begin
    nrst = 1'b0;
    #2
    nrst = 1'b1;
    #100
    nrst = 1'b0;
end

initial begin
    s_bit = 1'b0;
    #30
    s_bit = 1'b1;
end

initial begin
    $dumpfile("I2C_Master_tb.vcd");
    $dumpvars;
    #500
    $finish;
end

endmodule
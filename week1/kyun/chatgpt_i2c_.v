
Master Code-:
module master(data,address,clk,rw,sda,scl,register,data_wr);
  output reg sda;
  input [7:0] data;
  input [7:0] data_wr;
  reg [7:0]data_wr_dup;
  input clk;
  input rw;
  output reg scl;
  input [6:0] address;
  input [7:0] register;
  //
  reg [8:0] temp;
  reg [7:0] register2;
  reg pstate;
  reg scl2x;
  reg ack;
  reg a;
  integer i;
  integer n;
  initial begin
    i = 0;
    n = 0;
    scl2x = 0;
    ack = 1’b1;
    sda = 1;
    scl = 1;
    #5 sda = 0;  //START BIT condition starts here
end
  always @(negedge sda)
    if(scl==1) n=1;

always @(posedge clk)begin
  ack = 0;
  temp = {address,rw,ack};
  register2 = register;
  data_wr_dup = data_wr;
  if(n==1 && rw==1)
    repeat(50)begin
    #2 scl <= !scl;n=0;
    #1 scl2x <= !scl2x;n=0;
  end
  else if(n==1 && rw==0)
  repeat(64) begin
    #2 scl = !scl;
    #1 scl2x = !scl2x;n=0;
  end
end

always @(posedge clk)begin
  if(i==25 && rw==1)
  repeat(2)
  #1 scl2x = !scl2x;
  else if(i==32 && rw==0)
  repeat(2)
  #1 scl2x = !scl2x;end

  always @(posedge scl2x)begin
  if(i<=9)begin
  sda = temp[8];
  temp = temp<<1;
  end
  else if(i==12 || i==13)
  sda = 1’b0;
  else if(i>=14)begin
  sda = register2[7];
  register2 = register2<<1;
  end
  if(rw==0 && i>=23)begin
  sda = data_wr_dup[7];
  data_wr_dup = data_wr_dup<<1;
  end
i = i + 1;
if(i>32 && rw ==0)
sda= 1;
else if(i>25 && rw==1)
sda = 1;
end
slave slv(data,sda,scl);
endmodule

module slave(out,sda,scl);
input sda;
input scl;
output reg [7:0]out;
integer j = 0;
reg [6:0]temp;
reg [7:0]add;
reg rw;
reg [7:0]register_address;
reg bitin;
reg [7:0]storage[0:38];
initial
storage[37]=16;
parameter address = 7’b1101001;
always @(posedge scl)begin
//if({sda,scl}==2’b01)begin
bitin = sda;
if(j<8)
temp = {temp,bitin};
if(j==8)
            if(bitin==0)
                        rw = 0;
            else
                        rw = 1;
j = j +1 ;
if(temp==address && (j>15 && j<24) && rw==1)begin
            add = {add,bitin};
end
if(temp==address && rw == 0 && j>15 && j!=24 && j<33)begin
            add = {add,bitin};
end
else if(j==24)
            register_address = add;
if(j==33 && rw==0)
storage[register_address]=add;
out = storage[add];
end
endmodule
And here is the testbench _-:

module tbmast;
            // Inputs
            reg [6:0] address;
            reg [7:0] register;
            reg [7:0] data;
            reg [7:0] data_wr;
            reg clk;
            reg rw;
            // Outputs
            wire sda;
            wire scl;
            // Instantiate the Unit Under Test (UUT)
            master uut (
                        .address(address),
                        .register(register),
                        .clk(clk),
                        .rw(rw), 
                        .sda(sda),
                        .scl(scl),
                        .data(data),
                        .data_wr(data_wr)
            );

initial begin
                        // Initialize Inputs
                        address = 105;
                        register = 7’b0100101;
                        clk = 0;
                        rw = 0;
                        data_wr = 20;
                        // Wait 100 ns for global reset to finish
                        #100;
       
                        // Add stimulus here
            end
      always
                        #1 clk = !clk;
endmodule
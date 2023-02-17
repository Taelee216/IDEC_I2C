module sram_test 
#(
    parameter WIDTH = 8,
    parameter ADR = 8,
    parameter MAX = 256
)
(   
    // input
    input wire                  clk,
    input wire                  CSn,
    input wire                  WEn,
    input wire  [WIDTH-1:0]     WIdth_en,
    input wire  [ADR-1:0]       addr,
    input wire  [WIDTH-1:0]     wdata,
    // output
    output reg  [WIDTH-1:0]     rdata
);

reg [WIDTH-1:0] rmem [0:MAX];
reg [ADR-1:0]   raddr;

always @(posedge clk) begin
    if (!Csn) begin
        if(!WEn) begin
            rmem[addr] <= #1 wdata & ~WEn;
        end
        raddr <= #1 addr;
    end 
end

assign rdata = rmem[raddr];

endmodule







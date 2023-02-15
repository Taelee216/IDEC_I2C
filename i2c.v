module IDEC_i2c(
    input wire clk,
    input wire rst,
    input wire i,
    output reg out
);
//parameter for state define
parameter [3:0] IDLE = 4'd0, START = 4'd1, DEV_SEL = 4'd2, READ = 4'd3, WRITE = 4'd4;
parameter [3:0] ACK = 4'd5, REG_SEL = 4'd6, DATA = 4'd7, NACK = 4'd8, STOP = 4'd9;

reg [3:0] state, next_state;

//State register
always @(posedge clk, negedge rst) begin
    if (!rst) state <= IDLE;
    else state <= next_state;
end

//Next State Logic
always @(state, i) begin
    next_state = 4'bx;
    //out
    case(state)
        IDLE: if(i) next_state <= START; else next_state <= IDLE;
        START: if(i) next_state <= DEV_SEL; else next_state <= START;
        DEV_SEL: if(i) next_state <= READ; else next_state <= DEV_SEL;
        READ: if(i) next_state <= WRITE; else next_state <= READ;
        WRITE: if(i) next_state <= ACK; else next_state <= WRITE;
        ACK: if(i) next_state <= REG_SEL; else next_state <= ACK;
        REG_SEL: if(i) next_state <= DATA; else next_state <= REG_SEL;
        DATA: if(i) next_state <=  NACK; else next_state <= DATA;
        NACK: if(i) next_state <= STOP; else next_state <= NACK;
        STOP: if(i) next_state <= IDLE; else next_state <= STOP;
        default: next_state <= IDLE;
    endcase
end


endmodule
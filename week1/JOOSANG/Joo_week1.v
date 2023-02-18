module I2C_Master (
    input wire clk,
    input wire nrst,
    input wire i
);

reg [3:0] state;
reg [3:0] next_state;

//state define
parameter IDLE    = 4'd0;
parameter START   = 4'd1;
parameter DEV_SEL = 4'd2;
parameter READ    = 4'd3;
parameter WRITE   = 4'd4;
parameter ACK     = 4'd5;
parameter REG_SEL = 4'd6;
parameter DATA    = 4'd7;
parameter NACK    = 4'd8;
parameter STOP    = 4'd9;

always @(posedge clk, negedge nrst)
    if(~nrst) state <= IDLE;
    else state <= next_state;

//state machine    
always @* begin
    case (state)
        IDLE:  
            if() next_state = START;
            else next_state = IDLE;

        START:  
            next_state = DEV_SEL  

        DEV_SEL:
            if() next_state = WRITE;
            else if() next_state = READ;

        WRITE:
            next_state = REG_SEL;

        READ:
            next_state = REG_SEL;

        REG_SEL: 
            next_state = DATA;

        DATA:
            next_state = ACK;

        ACK:
             next_state = DATA;

        NACK:
            next_state = STOP;

        STOP:
            next_state = IDLE;

        default 
            next_state = STATE_IDLE;
    endcase
end




endmodule
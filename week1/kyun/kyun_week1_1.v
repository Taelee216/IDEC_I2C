module IDEC_i2c(
    //basic input
    input wire          clk,
    input wire          nrst,
    input wire          rw_sel, //1:read, 0:write
    //addr of device, register and input data
    input wire [6:0]    dev_addr,
    input wire [7:0]    data_in,
    input wire [7:0]    reg_addr,
    //SDA
    input wire          SDA_in,
    output reg          SDA_out,
    //SCL - sync to clk?
    output reg          SCL_out,

    output reg [7:0]    data_out,
);



//parameter for state define
parameter   IDLE = 4'd0, 
            START = 4'd1, 
            DEV_SEL = 4'd2, 
            READ = 4'd3, 
            WRITE = 4'd4,
            ACK = 4'd5,
            REG_SEL = 4'd6, 
            DATA = 4'd7,
            NACK = 4'd8, 
            STOP = 4'd9;

//Register Declaration
    //regs for state
reg [3:0] state         = 4'd0;
reg [3:0] next_state    = 4'd0;
reg [7:0] ireg          = 4'd0;         //for input reg addr
reg [6:0] idev          = 4'd0;         //for input device addr
reg [3:0] bit_cnt       = 4'd0;         //11 state, 4bit needed
    //reg for state change
reg [7:0] cnt           =4'd0;
    //reg for SCL
reg scl;

//State register
always @(posedge clk, negedge rst) begin
    if (!rst) state <= IDLE;
    else state <= next_state;
end
//Always for count variable
    //whty reg cnt has 8bit? -> use number 31
always @(posedge clk) 
    if(!rst)
        cnt <= 8'b0;
    else
        if(cnt < 8'd31) cnt <= cnt + 1;
        else cnt <= 8'b0;


//Next State Logic
always @(*) begin
    next_state = 4'bx;  //for inferred latch or initialization
    //out
    case(state)
        IDLE: 
            if(i) next_state <= START; 
            else next_state <= IDLE;
        START:          //read 7 bit input
            if(i) next_state <= DEV_SEL; 
            else next_state <= START;
        DEV_SEL: 
            if(i) next_state <= READ; 
            else next_state <= DEV_SEL;
        READ: 
            if(i) next_state <= WRITE; 
            else next_state <= READ;
        WRITE: 
            if(i) next_state <= ACK; 
            else next_state <= WRITE;
        ACK: 
            if(i) next_state <= REG_SEL; 
            else next_state <= ACK;
        REG_SEL: 
            if(i) next_state <= DATA; 
            else next_state <= REG_SEL;
        DATA: 
            if(i) next_state <=  NACK; 
            else next_state <= DATA;
        NACK: 
            if(i) next_state <= STOP; 
            else next_state <= NACK;
        STOP: 
            if(i) next_state <= IDLE; 
            else next_state <= STOP;

        default: 
            next_state <= IDLE;
    endcase
end

//State machine
always @ (posedge clk) begin
    case(state)
    IDLE:   //initialize dev_addr, reg_addr, scl, sda, bit_cnt
    begin
        dev_addr    <= 0;
        bit_cnt     <= 4'b0;
        SDA_out     <= 1'b0;
        SCL_out     <= 1'b0;
    end
    START:  //send start condition
    begin
        SDA_out     <= 1'b0;
    end
    endcase
end

endmodule
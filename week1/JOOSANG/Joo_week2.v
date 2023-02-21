 module I2C_Master (
    input wire clk,
    input wire nrst,
    input wire s_bit,
    //input wire RW_SEL,
    //input wire ack,
    
    //input wire [6:0] Device_Addr,
    //input wire [7:0] Data_in,
    //output reg [7:0] Data_out,

    output reg SCL,
    //input wire SDA_in,
    output reg SDA_out,
    output reg [3:0] state    
);


//input initial
reg RW_SEL_reg;
reg ack_reg;

reg SDA_reg;
reg SCL_reg;

reg clr=0;

reg [7:0] Data_reg = 0;
reg [7:0] Device_Addr_reg = 0;

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


reg [3:0] next_state = IDLE;

always @(posedge clk, negedge nrst)
    if(!nrst) state <= IDLE;
    else state <= next_state;

//state machine    
always @* begin
    case (state)
        IDLE:  
            if(s_bit) next_state = START;
            else next_state = IDLE;

        START:  
            next_state = DEV_SEL;  

        DEV_SEL :
		if (count == 8'd22 ) next_state = READ;		
		else next_state = DEV_SEL;
			

        /*DEV_SEL:
            if(RW_SEL_reg) next_state = WRITE;
            else next_state = READ;*/

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
            next_state = IDLE;
    endcase
end



always @(posedge clk) begin
case (state)
    IDLE :
    begin
        //Device_Addr_reg <= Device_Addr;
        SDA_out <= 1'b1;
        SCL <= 1'b1;
    end

    START :
    begin
        SDA_out <= 1'b0;   
    end

endcase
end




//precale
reg [1:0] counter = 0;

always @(posedge clk) begin

    if(counter==3) begin
        clr <= ~clr;
        count <= 0;
        end
    else counter <= counter+1;
       
end

always @(posedge clk) begin
    if(state==IDLE) SCL <= 1'b1;
    else SCL <= clr;
end



////////state임시로 count로 계산//////////
reg [7:0] count;

always @ (posedge clk) begin			
	if(!nrst) begin	// rst Active
		count <= 8'd31;
	end
	
	else begin
		if(count > 8'd0) count <= count - 8'd1;			
		else count <= 8'd31;					
	end
end
////////////////////////////////////////////////

endmodule

//////////////////////////////////////
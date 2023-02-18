module I2C_Master (

        input wire rst,
		input wire clk,
		input wire sel,
        input wire [7:0] Data_in,
        input wire [7:0] Reg_addr,
        input wire [6:0] Dev_addr,
        input wire SDA_in,
        output reg	 SDA_out,
        output reg	 SCL_out
);

localparam STATE_IDLE 				= 4'd0;
localparam STATE_START 				= 4'd1;
localparam STATE_DEV_SEL 			= 4'd2;
localparam STATE_READ 				= 4'd3;
localparam STATE_ACK_W			 	= 4'd4;
localparam STATE_REG_SEL	 		= 4'd5;
localparam STATE_ACK_REG		 	= 4'd6;
localparam STATE_READ 				= 4'd7;
localparam STATE_WRITE		 		= 4'd8;
localparam STATE_ACK_DATA			= 4'd9;
localparam STATE_NACK		 		= 4'd10;
localparam STATE_STOP				= 4'd11;

reg [3:0]  state = STATE_IDLE;
reg [3:0]  next_state = STATE_IDLE;
reg [7:0]  DATA;
reg [7:0]  register =0;
reg [6:0]  device =0;
reg [3:0]  bit_count = 4'd0;

reg	   SDA = 1'b1;
reg	   SCL = 1'b1;

reg [7:0] count;

always @ (posedge clk) begin
	if(!rst) begin
		state <= STATE_IDLE;
	end
	else begin
		state <= next_state;
	end
end

always @ (*) begin
	case (state)
	
		STATE_IDLE : 				
		if (rst) begin
			next_state = STATE_START;
		end
		else begin
			next_state = STATE_IDLE;
		end

		STATE_START:
		if (count == 8'd29) begin
			next_state = STATE_DEV_SEL;
		end
		else  begin
			next_state = STATE_IDLE;
		end
    
    	STATE_DEV_SEL: 
		if (count == 8'd22 ) begin
			next_state = STATE_RW;
		end
        else begin 
			next_state =STATE_DEV_SEL;
        end
		
		STATE_RW:
		if (count == 8'd21) begin
			next_state = STATE_ACK_W;
		end
		else begin
		next_state = STATE_IDLE;
		end

    	STATE_ACK_W : 
		if (count == 8'd21) begin
			next_state = STATE_ACK_W;
        end 
        else begin 
			next_state = STATE_IDLE;
          end
    	STATE_REG_SEL : 	 
		if (count == 8'd12) begin
			next_state = STATE_ACK_REG;
		end
		else begin
			next_state = STATE_REG_SEL;
		end

    	STATE_ACK_REG :   
		if (rst) begin 
			next_state = STATE_READ;
          end 
        else begin 
			next_state = STATE_WRITE;
          end

    	STATE_READ :  	
		if (rst) begin 
			next_state = STATE_WRITE; 
          end 
        else begin 
			next_state = STATE_READ;
          end
    	STATE_ACK_DATA : 	 
		if (rst) begin 
			next_state = STATE_NACK;
          end 
        else begin 
			next_state = STATE_ACK_DATA;
		end
          end

    	STATE_NACK: 
		if (rst) begin 
			next_state = STATE_STOP; 
          end 
          else begin 
			next_state = STATE_NACK;

    	STATE_STOP: 
		if (rst) begin 
			next_state = STATE_IDLE; 
          end 
          else begin 
			next_state = STATE_STOP;
          end
	endcase
end
endmodule
	 

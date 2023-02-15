module I2C_Master (

input wire rst,clk,sel,
output reg [3:0] state

);

reg [3:0] next_state;

localparam STATE_IDLE 				= 4'd0;
localparam STATE_START 				= 4'd1;
localparam STATE_DEV_SEL 			= 4'd2;
localparam STATE_READ 				= 4'd3;
localparam STATE_WRITE		 		= 4'd4;
localparam STATE_ACK			 	= 4'd5;
localparam STATE_REG_SEL	 		= 4'd6;
localparam STATE_DATA		 		= 4'd7;
localparam STATE_NACK		 		= 4'd8;
localparam STATE_STOP				= 4'd9;

always @ (posedge clk , negedge rst) begin
	if(~rst)begin
		state <= STATE_IDLE;
	end

	else begin
		state <= next_state;
	end
end

always @ (*) begin
	case (state)
		STATE_IDLE : 				
		if (sel) begin
			next_state = STATE_START;
		end
		else begin
			next_state = STATE_IDLE;
		end

		STATE_START : 
		if (sel) begin
			next_state = STATE_DEV_SEL;
		end
		else  begin
			next_state = STATE_START;
		end

		STATE_DEV_SEL:
		 if (sel) begin
			next_state = STATE_READ;
		end
		else begin
			next_state = STATE_DEV_SEL;
            	end

		STATE_READ : 				
		if (sel) begin
			next_state = STATE_WRITE;
		end
		else begin
			next_state = STATE_READ;
		end
		
		STATE_WRITE : 				
		if (sel) begin
			next_state = STATE_ACK;
		end
		else begin
			next_state = STATE_WRITE;
		end

		STATE_ACK : 				
		if (sel) begin
			next_state = STATE_REG_SEL;
		end
		else begin
			next_state = STATE_ACK;
		end

		STATE_REG_SEL : 				
		if (sel) begin
			next_state = STATE_DATA;
		end
		else begin
			next_state = STATE_REG_SEL;
		end

		STATE_DATA : 				
		if (sel) begin
			next_state = STATE_NACK;
		end
		else begin
			next_state = STATE_DATA;
		end
		
		STATE_NACK : 				
		if (sel) begin
			next_state = STATE_STOP;
		end
		else begin
			next_state = STATE_NACK;
		end

		STATE_STOP : 				
		if (sel) begin
			next_state = STATE_IDLE;
		end
		else begin
			next_state = STATE_STOP;
		end

	endcase
end
endmodule

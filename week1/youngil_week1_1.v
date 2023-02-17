module I2C_Master (

input	wire [7:0] Data_in,
input	wire [7:0] Reg_addr,
input	wire [6:0] Dev_addr,
input	wire	   clk,rst,RW_sel,

input	wire	 SDA_in,
output	reg	 SDA_out,
output	reg	 SCL_out

);


localparam STATE_IDLE 				= 4'd0;
localparam STATE_START 				= 4'd1;
localparam STATE_DEV_SEL 			= 4'd2;
localparam STATE_RW				= 4'd3;
localparam STATE_READ 				= 4'd4;
localparam STATE_WRITE		 		= 4'd5;
localparam STATE_ACK			 	= 4'd6;
localparam STATE_REG_SEL	 		= 4'd7;
localparam STATE_DATA		 		= 4'd8;
localparam STATE_NACK		 		= 4'd9;
localparam STATE_STOP				= 4'd10;

reg [3:0]  state = STATE_IDLE;
reg [3:0]  next_state = STATE_IDLE;
reg [7:0]  Register = 0;
reg [6:0]  Device = 0;
reg 	   ACK = 1;

reg	   SDA = 1'b1;
reg	   SCL = 1'b1;

reg	   START_done = 1'b0;
reg	   DEV_SEL_done = 1'b0;
reg	   REG_SEL_done = 1'b0;




reg [31:0] count = 32'b0;

reg [3:0]  bit_count = 3'b0;

////////////////////////////////////////////////////////////////////////////////////
always @ (posedge SCL) begin
	SDA = SDA_in + SDA_out;			
end
////////////////////////////////////////////////////////////////////////////////////
always @ (posedge SCL) begin
	if(~rst)begin
		state <= STATE_IDLE;
	end

	else begin
		state <= next_state;
	end
end
////////////////////////////////////////////////////////////////////////////////////
always @ (*) begin
	case (state)
		STATE_IDLE : 				
		if (rst) begin
			next_state = STATE_START;
		end
		else begin
			next_state = STATE_IDLE;
		end

		STATE_START : 
		if (START_done) begin
			next_state = STATE_DEV_SEL;
		end
		else  begin
			next_state = STATE_START;
		end

		STATE_DEV_SEL:
		 if (DEV_SEL_done) begin
			next_state = STATE_READ;
		end
		else begin
			next_state = STATE_DEV_SEL;
            	end
		
		STATE_RW:
		 if (rst) begin
			next_state = STATE_ACK;
		end
		else begin
			next_state = STATE_RW;
            	end

		STATE_READ :  				
		if (rst) begin
			next_state = STATE_WRITE;
		end
		else begin
			next_state = STATE_READ;
		end
		
		STATE_WRITE : 				
		if (rst) begin
			next_state = STATE_ACK;
		end
		else begin
			next_state = STATE_WRITE;
		end

		STATE_ACK : 				
		if (rst) begin
			next_state = STATE_REG_SEL;
		end
		else begin
			next_state = STATE_ACK;
		end

		STATE_REG_SEL : 				
		if (rst) begin
			next_state = STATE_DATA;
		end
		else begin
			next_state = STATE_REG_SEL;
		end

		STATE_DATA : 				
		if (rst) begin
			next_state = STATE_NACK;
		end
		else begin
			next_state = STATE_DATA;
		end
		
		STATE_NACK : 				
		if (rst) begin
			next_state = STATE_STOP;
		end
		else begin
			next_state = STATE_NACK;
		end

		STATE_STOP : 				
		if (rst) begin
			next_state = STATE_IDLE;
		end
		else begin
			next_state = STATE_STOP;
		end

	endcase
end
////////////////////////////////////////////////////////////////////////////////////
always @ (posedge SCL) begin
	case (state)
		STATE_IDLE : // Initialization
		begin
			Register <= Reg_addr;
			Device <= Dev_addr;
			ACK <= 1;
			SCL <= 1'b1;
			SDA_out <= 1'b1;
			bit_count <= 3'd1;
		end
		
		STATE_START : // Write Start bit(0) on SDA (From Master to Slave)
		begin
			SDA_out <= 1'b0;
			START_done <= 1'b1;
			bit_count <= 3'd7;	// set bit_count 7 for Next STATE(STATE_DEV_SEL)
		end

		STATE_DEV_SEL : // Write Device Address [6:0] on SDA (From Master to Slave)
		begin
			if(bit_count) begin
				if(Dev_addr[bit_count - 1]) begin
					SDA_out <= 1'b1;
				end
				else begin
					SDA_out <= 1'b0;
				end
				bit_count <= bit_count - 1'b1;
				START_done <= 1'b0;
			end
			else begin
				DEV_SEL_done = 1'b1;
			end
		end

		STATE_RW :	//Write RW bit on SDA (From Master to Slave)
		begin	
			if(RW_sel & REG_SEL_done) begin
				SDA_out <= 1'b1;
			end
			else  begin
				SDA_out <= 1'b0;
			end

		end
		
	endcase
end
////////////////////////////////////////////////////////////////////////////////////

always @ (posedge clk) begin			// 5 MHz clk , SCL
	if(!rst) begin	//(rst == 0)
		count <= 32'b0;
	end
	
	else begin	// (rst == 1)
		if(SDA == 0) begin	// count & SCL Activation, after SDA Low Condition
			if(count == 9) begin
				count <= count + 32'b0;
				SCL <= SCL ^ 1'b1;
			end
			else begin
				count <= count + 32'd1;
			end
		end

		else begin
			count <= 32'd0;
		end
	end
end

////////////////////////////////////////////////////////////////////////////////////
endmodule

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
localparam STATE_ACK_W			 	= 4'd4;

localparam STATE_REG_SEL	 		= 4'd5;
localparam STATE_ACK_REG		 	= 4'd6;

localparam STATE_READ 				= 4'd7;
localparam STATE_WRITE		 		= 4'd8;

localparam STATE_ACK_DATA			= 4'd9;
localparam STATE_NACK		 		= 4'd10;
localparam STATE_STOP				= 4'd11;

localparam STATE_RESTART			= 4'd12;

reg [3:0]  state = STATE_IDLE;
reg [3:0]  next_state = STATE_IDLE;

reg [3:0]  bit_count = 4'd0;
reg [3:0]  SCL_count = 4'd0;

wire	   SDA;
wire	   SCL;


reg [8:0] count;
reg [7:0] count1;

////////////////////////////////////////////////////////////////////////////////////

always @ (posedge clk) begin
	if(!rst)begin
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
		if (rst) begin
			next_state = STATE_DEV_SEL;
		end
		else  begin
			next_state = STATE_IDLE;
		end

		STATE_DEV_SEL :
		if (rst) begin
			next_state = STATE_RW;
		end

		else if (rst&(RW_sel)) begin
			next_state = STATE_RW;
		end

		else begin
			next_state = STATE_DEV_SEL;
            	end
		
		STATE_RW:
		if (rst) begin
			next_state = STATE_ACK_W;
		end
		else if (rst&(RW_sel)) begin
			next_state = STATE_ACK_W;
		end

		else begin
			next_state = STATE_IDLE;
            	end

		STATE_ACK_W :  				
		if (rst & (SDA_in == 0)) begin
			next_state = STATE_REG_SEL;
		end
		else if (rst&(RW_sel)) begin
			next_state = STATE_READ;
		end
		else begin
			next_state = STATE_IDLE;
		end

		STATE_REG_SEL : 				
		if (rst) begin
			next_state = STATE_ACK_REG;
		end
		else begin
			next_state = STATE_REG_SEL;
		end
		
		STATE_ACK_REG : 				
		if (rst & (SDA_in == 0)) begin
			if(RW_sel) begin
				next_state = STATE_RESTART;
			end
			else begin
				next_state = STATE_WRITE;
			end
		end
		else begin
			next_state = STATE_IDLE;
		end
		
		STATE_READ :  				
		if (rst) begin
			next_state = STATE_NACK;
		end
		else begin
			next_state = STATE_READ;
		end
		
		STATE_WRITE : 				
		if (rst) begin
			next_state = STATE_ACK_DATA;
		end
		else begin
			next_state = STATE_WRITE;
		end

		STATE_ACK_DATA : 				
		if (rst) begin
			next_state = STATE_STOP;
		end
		else begin
			next_state = STATE_IDLE;
		end
		
		STATE_NACK : 				
		if (rst) begin
			next_state = STATE_STOP;
		end
		else begin
			next_state = STATE_IDLE;
		end

		STATE_STOP : 		
		if (rst) begin
			next_state = STATE_IDLE;
		end
		else begin
			next_state = STATE_IDLE;
		end
		
		STATE_RESTART :
		if (rst) begin
			next_state = STATE_DEV_SEL;
		end
		else begin
			next_state = STATE_IDLE;
		end

		default next_state = STATE_IDLE;
	endcase
end

////////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk) begin
	case (state)  
		STATE_IDLE : // Initialization
		begin
			SCL_out <= 1'b1;
			SDA_out <= 1'b1;
			bit_count <= 4'd0;
			SCL_count <= 4'd0;
			count1<= 8'd0;
			count<= 0;
		end
		
		STATE_START : // Write Start bit(0) on SDA (From Master to Slave)
		begin
			SDA_out <= 1'b0;
			bit_count <= 4'd7;
		end
		
		STATE_DEV_SEL : // Write Device Address [6:0] on SDA (From Master to Slave)
		begin
			if(bit_count) begin
				if(Dev_addr[bit_count - 4'd1]) begin
					SDA_out <= 1'b1;
				end
				else begin
					SDA_out <= 1'b0;
				end
			end
			bit_count = bit_count - 4'd1;
		end

		STATE_RW :	//Write W bit on SDA (From Master to Slave)
		begin	
			if ((RW_sel==1)&(count==8'd12)) begin
				SDA_out <= 1'b1;
			end
			else begin
				SDA_out <= 1'b0;
			end
		end

		STATE_ACK_W :			//Read ARK bit (From Slave to Master)
		begin	
			SDA_out <= 1'b0;
			bit_count <= 4'd8;
		end
		
		STATE_REG_SEL : // Write Register Address [7:0] on SDA (From Master to Slave)
		begin
			if(bit_count) begin
				if(Reg_addr[bit_count - 4'd1]) begin
					SDA_out <= 1'b1;
				end
				else begin
					SDA_out <= 1'b0;
				end
			end
			bit_count = bit_count - 4'd1;
		end

		STATE_ACK_REG :			//Read ARK bit (From Slave to Master)
		begin	
			SDA_out <= 1'b0;
			if(RW_sel)begin
				bit_count <= 4'd0;
			end
			else begin
				bit_count <= 4'd8;
			end
		end
		
		STATE_WRITE : //Write Data [7:0] on SDA (From Master to Slave)
		begin
			if(bit_count) begin
				if(Data_in[bit_count - 4'd1]) begin
					SDA_out <= 1'b1;
				end
				else begin
					SDA_out <= 1'b0;
				end
			end
			bit_count <= bit_count - 4'd1;
		end

		STATE_READ : //Read Data [7:0] on SDA (From Slave to Master)
		begin
			SDA_out <= 1'b0;
			bit_count <= bit_count - 4'd1;
		end

		STATE_ACK_DATA : 	//Read ARK bit (From Slave to Master)
		begin
			SDA_out <= 1'b0;
		end

		STATE_NACK : 		//Read NACK bit (From Slave to Master)
		begin
			SDA_out <= 1'b1;
		end

		STATE_STOP : //Write STOP bit on SDA (From Master to Slave)
		begin
			SDA_out <= 1'b1;
		end
		
		STATE_RESTART : 
		begin
			SDA_out <= 1'b0;
			bit_count <= 4'd7;
		end

	endcase
end

////////////////////////////////////////////////////////////////////////////////////

always @ (posedge clk) begin			
	if(!rst) begin
		count <= 8'd0;
	end
	
	else begin
		count <= count + 8'd1;

	end
end

////////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk) begin
	if ( state >= STATE_START ) begin
		SCL_count <= SCL_count + 4'd1;
		if (SCL_count == 3) begin
       			 SCL_count <= 4'd0;
       			 SCL_out <= !SCL_out;
    		end
	end
end
////////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk) begin
	count1 <= count1 + 8'd1;
	if ( count1 == 7) begin
	count1 <= 8'd0;
	bit_count <= bit_count + 4'd1;
	end
end

////////////////////////////////////////////////////////////////////////////////////
assign SDA = SDA_in + SDA_out;
assign SCL = SCL_out;
 	
////////////////////////////////////////////////////////////////////////////////////

endmodule

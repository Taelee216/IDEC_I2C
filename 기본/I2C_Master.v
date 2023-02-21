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
localparam STATE_RESTART			= 4'd10;
localparam STATE_NACK		 		= 4'd11;

localparam STATE_STOP				= 4'd12;
localparam STATE_FINISH				= 4'd13;




reg [3:0]  state = STATE_IDLE;
reg [3:0]  next_state = STATE_IDLE;

reg [3:0]  bit_count = 4'd0;
reg [3:0]  SCL_count = 4'd0;

wire	   SDA;
wire	   SCL;


reg [8:0] count	= 9'd0;
reg [3:0] count1 = 4'd0;

///////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge clk) begin
	if(!rst)begin
		state <= STATE_IDLE;
	end

	else begin
		state <= next_state;
	end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (*) begin
	case (state)
		STATE_IDLE : 				
		if (count == 9'd5) begin
			next_state = STATE_START;
		end
		else begin
			next_state = STATE_IDLE;
		end

		STATE_START : 
		if (count == 9'd10) begin
			next_state = STATE_DEV_SEL;
		end
		else if (count <= 9'd9)begin
			next_state = STATE_START;
		end
		else  begin
			next_state = STATE_IDLE;
		end

		STATE_DEV_SEL :
		if (count == 9'd66) begin
			next_state = STATE_RW;
		end

		else begin
			next_state = STATE_DEV_SEL;
		end
		
		STATE_RW:
		if (count == 9'd74 ) begin
			next_state = STATE_ACK_W;
		end

		else begin
			next_state = STATE_RW;
            	end

		STATE_ACK_W :  				
		if (count == 9'd82 & (SDA_in == 1'b0)) begin
			next_state = STATE_REG_SEL;
		end
		else if ((count <= 9'd81) & (SDA_in == 1'b0)) begin
			next_state = STATE_ACK_W;
		end

		else begin
			next_state = STATE_IDLE;
		end

		STATE_REG_SEL : 				
		if (count == 9'd146 ) begin
			next_state = STATE_ACK_REG;
		end
		else begin
			next_state = STATE_REG_SEL;
		end
		
		STATE_ACK_REG : 				
		if (count == 9'd154 & (SDA_in == 1'b0)) begin
			if(RW_sel) begin
				next_state = STATE_RESTART;
			end

			else begin
				next_state = STATE_WRITE;
			end
		end

		else if((count<= 9'd153) & (SDA_in == 1'b0)) begin
			next_state = STATE_ACK_REG;
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
		if (count == 9'd218 ) begin
			next_state = STATE_ACK_DATA;
		end
		else begin
			next_state = STATE_WRITE;
		end

		STATE_ACK_DATA : 				
		if ((count == 9'd226) & (SDA_in == 1'b0)) begin
			next_state = STATE_STOP;
		end
		else if ((count <= 9'd225) & (SDA_in == 1'b0)) begin
			next_state = STATE_ACK_DATA;
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
		if ((count == 9'd234) & (RW_sel == 1'b0)) begin
			next_state = STATE_FINISH;
		end
		else if (count <= 9'd233) begin
			next_state = STATE_STOP;
		end
		else begin
			next_state = STATE_STOP;
		end
		
		STATE_RESTART :
		if (rst) begin
			next_state = STATE_DEV_SEL;
		end
		else begin
			next_state = STATE_IDLE;
		end

		STATE_FINISH :
		if (count == 242) begin
			next_state = STATE_IDLE;
		end
		else begin
			next_state = STATE_FINISH;
		end

		default next_state = STATE_IDLE;
	endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////
always @ (posedge clk) begin
	case (state)  
		STATE_IDLE : //Initialization
		begin
			SCL_out <= 1'b1;
			SDA_out <= 1'b1;
			bit_count <= 4'd0;
			SCL_count <= 4'd0;
			count1 <= 4'd0;
			count <= 9'd0;
		end
		
		STATE_START : //Write Start bit(0) on SDA (From Master to Slave)
		begin
			
			if(count == 9'd10) begin
				bit_count <= 4'd7;
				SDA_out <= 1'b0;
			end
			else begin
				SDA_out <= 1'b0;
			end
		end
		
		STATE_DEV_SEL : //Write Device Address [6:0] on SDA (From Master to Slave)
		begin
			if(bit_count) begin
				if(Dev_addr[bit_count - 4'd1]) begin
					SDA_out <= 1'b1;
				end
				else begin
					SDA_out <= 1'b0;
				end
			end
		end

		STATE_RW :	//Write W bit on SDA (From Master to Slave)
		begin	
				//  ++++++++ if Read mode
				SDA_out <= 1'b0;
		end

		STATE_ACK_W :			//Read ARK bit (From Slave to Master)
		begin	
			if(count == 9'd82) begin
				SDA_out <= 1'b0;
				bit_count <= 4'd8;
			end
			else begin
				SDA_out <= 1'b0;
			end	
		end
		
		STATE_REG_SEL : //Write Register Address [7:0] on SDA (From Master to Slave)
		begin
			if(bit_count) begin
				if(Reg_addr[bit_count - 4'd1]) begin
					SDA_out <= 1'b1;
				end
				else begin
					SDA_out <= 1'b0;
				end
			end
		end

		STATE_ACK_REG :			//Read ARK bit (From Slave to Master)
		begin	
			if(count == 9'd154 ) begin
				SDA_out <= 1'b0;
				bit_count <= 4'd8;
			end
			else begin
				SDA_out <= 1'b0;
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
		
		STATE_FINISH : //Write RESTART bit on SDA (From Master to Slave)
		begin
			if(SCL_out == 1'b1)begin
				SDA_out <= 1'b1;
			end
		end
		
		STATE_RESTART : //Write RESTART bit on SDA (From Master to Slave)
		begin
			SDA_out <= 1'b0;
			bit_count <= 4'd7;
		end

	endcase
end

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									// count :	 			   //		
always @ (posedge clk) begin					     	// count is clk based count     	   //	
	if(!rst) begin						        // count controls STATE		           //
		count <= 8'd0;					     	// ####################################### //
	end							        // # a Period of count = 2 period of clk # //
									// ####################################### //
	else begin							/////////////////////////////////////////////
		if((count == 9'd242) & (RW_sel == 1'b0)) begin							   //
			count <= 9'd0;										   //
		end												   //
		else if((count == 9'd320) & (RW_sel == 1'b1)) begin						   //
			count <= 9'd0;										   //
		end												   //
		else begin											   //
			count <= count + 8'd1;									   //
		end									  			   //
	end													   //
end														   //
														   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
								    // SCL_count :				   //
always @ (posedge clk) begin
	if ( STATE_START <= state ) begin
		SCL_count <= SCL_count + 4'd1;
		if (SCL_count == 3) begin
       			 SCL_count <= 4'd0;
       			 SCL_out <= !SCL_out;
    		end
	end
	else if (state == STATE_FINISH) begin
		SCL_count <= 4'd1;										   //
	end													   //
	else begin												   //
		SCL_count <= 4'd0;										   //
	end													   //
														   //
end														   //
								   						   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
								   // count1 :					   //
always @ (posedge clk) begin					   // count1 is clk based count for bit_count      //
	if(rst)begin						   // active condition : bit_count is set          //
		if(bit_count >0) begin				   // a Period of count1 = 2 period of clk	   //
			if ( count1 == 4'd7) begin		   // bit_count :   				   //
				count1 <= 4'd0;			   // bit count is count1 based count -            //
				bit_count <= bit_count - 4'd1;	   // To count data bits			   // 
			end					   // a Preriod of bit_count = 2 period of count1  //
								   // ############################################ //
			else begin				   // # a Preriod of bit_count = 8 period of clk # //
				count1 <= count1 + 4'd1;	   // ############################################ //
			end					   //////////////////////////////////////////////////
		end												   //
		else begin											   //
			count1 <= 4'd0;										   //
		end												   //
	end													   //
	else begin												   //
		count1 <= 4'd0;											   //
	end													   //
end														   //
														   //
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									      // SDA & SCL : 			   //
assign SDA = SDA_in + SDA_out;						      // SDA is a wire for signal analysis //
assign SCL = SCL_out;							      // SCL is a wire for signal analysis //
									      ///////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

endmodule
module I2C_EEPROM (

input	wire	SDA_out,
input	wire	SCL,
input	wire	rst,
output	reg	SDA_in

);

localparam STATE_IDLE 				= 4'd0;
localparam STATE_START 				= 4'd1;
localparam STATE_DEV_SEL 			= 4'd2;
localparam STATE_RW					= 4'd3;
localparam STATE_ACK_RW			 	= 4'd4;

localparam STATE_REG_SEL	 		= 4'd5;
localparam STATE_ACK_REG		 	= 4'd6;

localparam STATE_READ 				= 4'd7;
localparam STATE_WRITE		 		= 4'd8;

localparam STATE_ACK_DATA			= 4'd9;
localparam STATE_RESTART			= 4'd10;
localparam STATE_NACK		 		= 4'd11;

localparam STATE_STOP				= 4'd12;


reg [6:0] Dev_addr = 7'd0;
reg [7:0] Reg_addr = 8'd0;
reg [7:0] Data = 8'd0;
reg 	  RW_sel = 1'b0;
reg 	  Enable = 1'b0;

reg [7:0] e_count = 8'd0;
reg [3:0] bit_count = 4'd0;

reg [3:0] state_E = STATE_DEV_SEL;
reg [3:0] next_state = STATE_DEV_SEL;

///////////////////////////////////////////////////////////////////////////////////////////////////////
initial
begin
	SDA_in <= 1'b0;
	bit_count <= 4'd8;
	
	Dev_addr <= 7'd0;
	Data <= 8'd0;
	RW_sel <= 1'b0;
	Enable <= 1'b0;
end	

///////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge SCL) begin
	if(!rst)begin
		state_E <= STATE_DEV_SEL;
	end

	else begin
		state_E <= next_state;
	end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (SCL) begin
	case (state_E)
/*
		STATE_IDLE : 
		if  (SDA_out == 1'b0)  begin
			next_state = STATE_DEV_SEL;
		end
		else begin
			next_state = STATE_IDLE;
		end
*/
		STATE_DEV_SEL : 				
		if (e_count == 8'd7) begin
			next_state = STATE_RW;
		end
		else begin
			next_state = STATE_DEV_SEL;
		end
		
		STATE_RW : 				
		if (e_count == 8'd8) begin
			next_state = STATE_ACK_RW;
		end
		else begin
			next_state = STATE_DEV_SEL;
		end
		
		STATE_ACK_RW : 				
		if ( (e_count == 8'd9) & (SDA_in == 1'b0) & (Dev_addr == 7'b1111111) ) begin
			next_state = STATE_REG_SEL;
		end
		else begin
			next_state = STATE_DEV_SEL;
		end
		
		STATE_REG_SEL : 				
		if (e_count == 8'd17) begin
			next_state = STATE_ACK_REG;
		end
		else begin
			next_state = STATE_REG_SEL;
		end

		STATE_ACK_REG : 				
		if ( (e_count == 8'd18) & (SDA_in == 1'b0) ) begin
			next_state = STATE_WRITE;
		end
		else begin
			next_state = STATE_DEV_SEL;
		end

		STATE_WRITE : 				
		if (e_count == 8'd26) begin
			next_state = STATE_ACK_DATA;
		end
		else begin
			next_state = STATE_WRITE;
		end
		
		STATE_ACK_DATA :
		if (e_count == 8'd26) begin
			next_state = STATE_STOP;
		end
		else begin
			next_state = STATE_IDLE;
		end
		
		STATE_STOP :
		begin
			if( (SCL == 1'b1) & (SDA_out == 1'b1) ) begin
				next_state = STATE_IDLE;
			end
			else begin
				next_state = STATE_STOP;
			end
		end
		
	
	endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////

always @ (posedge SCL) begin
	case (state_E)

		STATE_DEV_SEL : 
		begin
			if(bit_count == 4'd0) begin
				if(Dev_addr == 7'b1111111) begin
					SDA_in <= 1'b0;
				end
				else begin
					SDA_in <= 1'b1;
				end
			end
			else begin
				Dev_addr [bit_count - 1'b1] <= SDA_out;
			end
		end
		
		STATE_RW :
		begin
			if(SDA_out == 1'b1)begin
				RW_sel <= 1'b1;
			end
			else begin
				RW_sel <= 1'b0;
			end
		end

		STATE_ACK_RW :
		begin
			bit_count <= 4'd8;
		end
		
		STATE_REG_SEL : 
		begin
			if(bit_count != 4'd0) begin
			Reg_addr [bit_count - 4'd1] <= SDA_out;
			end

			else begin
				if( (e_count == 8'd18) & (bit_count != 4'd0) ) begin
					SDA_in <= 1'b1;
				end
				else begin
					SDA_in <= 1'b0;
				end	
		
			end

		end

		STATE_ACK_REG :
		begin
			bit_count <= 4'd8;

			
			
		end

		STATE_WRITE :
		begin
			Data [bit_count - 4'd1] <= SDA_out;

			if( (e_count >= 8'd25) & (bit_count == 4'd1) ) begin
				SDA_in <= 1'b0;
			end
			else begin
				SDA_in <= 1'b1;
			end	
		end
		
		STATE_ACK_DATA :
		begin

		end

		STATE_STOP :
		begin
			
		end



	endcase
end

///////////////////////////////////////////////////////////////////////////////////////////////////////

always @ ( posedge SCL ) begin
	if((!rst) | (SDA_in==1'b1))begin
		e_count <= 8'd0;
	end
	else begin
		if( state_E > STATE_IDLE) begin
			e_count <= e_count + 8'd1;
		end
		else begin
			e_count <= 8'd0;
		end
	end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////

always @ ( posedge SCL ) begin
	if((!rst) | (SDA_in==1'b1))begin
		bit_count <= 4'd7;
		SDA_in <= 1'b0;
		
		Dev_addr <= 7'd0;
		Data <= 8'd0;
		RW_sel <= 1'b0;
		Enable <= 1'b0;

	end

	else begin
		if(bit_count > 4'd0) begin
			bit_count <= bit_count - 4'd1;
		end
	end
end

///////////////////////////////////////////////////////////////////////////////////////////////////////
endmodule
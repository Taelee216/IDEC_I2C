module fsm(
    input clk,
    input nrst,
    input [7:0] addr,


    inout [7:0]data
);
parameter idle = 3'd1,
          start = 3'd2,
          dev_sel = 3'd3,
          read = 3'd4,
          write = 3'd5,
          ack = 3'd6,
          reg_sel = 3'd7,
          data = 3'd8,
          nack = 3'd9,
          stop = 3'd10;
reg sda_en;
reg scl_en;
reg [3:0] state, next;
reg [7:0] data;
reg [7:0] reg_addr;
reg [6:0] device_addr;

always @(posedge clk, negedge rst)begin
    if(!rst) state <= IDLE;
    else state <= next;
end
localparam  = i;
reg start;



always @(*)begin
    case(state)
    idle : if(i) begin next <= start; end else next <= idle;

    start :  next <= dev_sel; 

    dev_sel : if(i) begin next <= read; end else next <= idle;

    read : if(i) begin next <= write; end else next <= idle;

    write : if(i) begin next <= ack; end else next <= idle;

    ack : if(i) begin next <= reg_sel; end else next <= idle;

    reg_sel : if(i) begin next <= data; end else next <= idle;

    data : if(i) begin next <= nack;end else next <= idle;

    nack : if(i) begin next <= stop;end else next <= idle;

    stop : if(i) begin next <= idle; end else next <= idle;

    endcase
end

localparam  = i;
reg scl_en_r;
always @(posedge clk, negedge nrst)begin
    case(state)
    idle : begin // variables set
    sda_en <= 1'b1; scl_en <= 1'b1; scl_en_r <= 1'b1;
    end

    start :begin sda_en <= 1'b0;  scl_en_r <= 1'b0; scl_en <= scl_en_r; end

    dev_sel : if(i) begin next <= read; end else next <= idle;

    read : if(i) begin next <= write; end else next <= idle;

    write : if(i) begin next <= ack; end else next <= idle;

    ack : if(i) begin next <= reg_sel; end else next <= idle;

    reg_sel : if(i) begin next <= data; end else next <= idle;

    data : if(i) begin next <= nack;end else next <= idle;

    nack : if(i) begin next <= stop;end else next <= idle;

    stop : if(i) begin next <= idle; end else next <= idle;
    endcase
end


endmodule
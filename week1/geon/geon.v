module fsm();
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
reg [3:0] state, next;

always @(posedge clk, negedge rst)begin
    if(!rst) state <= IDLE;
    else state <= next;
end
localparam  = i;
always @(*)begin
    case(state)
    idle : if(i) begin next <= start end else next <= idle;
    start : if(i) begin next <= start end else next <= idle;
    dev_sel : if(i) begin next <= start end else next <= idle;
    read : if(i) begin next <= start end else next <= idle;
    write : if(i) begin next <= start end else next <= idle;
    ack : if(i) begin next <= start end else next <= idle;
    reg_sel : if(i) begin next <= start end else next <= idle;
    data : if(i) begin next <= start end else next <= idle;
    nack : if(i) begin next <= start end else next <= idle;
    stop : if(i) begin next <= start end else next <= idle;
    endcase

end
always @(posedge clk)begin
case(state)
 idle : if(i) begin next <= start end else next <= idle;
    start : if(i) begin next <= start end else next <= idle;
    dev_sel : if(i) begin next <= start end else next <= idle;
    read : if(i) begin next <= start end else next <= idle;
    write : if(i) begin next <= start end else next <= idle;
    ack : if(i) begin next <= start end else next <= idle;
    reg_sel : if(i) begin next <= start end else next <= idle;
    data : if(i) begin next <= start end else next <= idle;
    nack : if(i) begin next <= start end else next <= idle;
    stop : if(i) begin next <= start end else next <= idle;

endcase 

end


endmodule
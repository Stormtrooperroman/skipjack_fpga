module skipjack_iterative (
    input logic rst,
    input logic clk,

    input logic [0:79] key,

    input  logic [63:0] s_axis_tdata,
    input  logic        s_axis_tvalid,
    output logic        s_axis_tready,

    output logic [63:0] m_axis_tdata,
    output logic        m_axis_tvalid,
    output logic        raw_axis_tvalid,
    input  logic        m_axis_tready
);

  parameter [2:0] IDLE = 3'b000,
                  ROUND_START = 3'b001,
                  WAIT_ROUND = 3'b010,
                  UPDATE_BLOCK = 3'b011,
                  DONE = 3'b100;
                  
  logic [2:0] state, next_state;

  logic [4:0]  counter;
  logic [63:0] block, enc_block;
  logic        last_round;
  
  logic [15:0] round_s_axis_tdata;
  logic        round_s_axis_tvalid;
  logic        round_s_axis_tready;
  logic [15:0] round_m_axis_tdata;
  logic        round_m_axis_tvalid;
  logic        round_m_axis_tready;
  
  logic [15:0] temp_data;

  assign last_round = &counter;

  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end

  always @(*) begin
    next_state = state;
    case(state)
      IDLE: 
        if (s_axis_tvalid && m_axis_tready) 
          next_state = ROUND_START;
      
      ROUND_START:
        if (round_s_axis_tready)
          next_state = WAIT_ROUND;
          
      WAIT_ROUND:
        if (round_m_axis_tvalid)
          next_state = UPDATE_BLOCK;
          
      UPDATE_BLOCK:
        if (last_round)
          next_state = DONE;
        else
          next_state = ROUND_START;
          
      DONE:
        if (s_axis_tvalid)
          next_state = IDLE;
          
      default:
        next_state = IDLE;
    endcase
  end

  always @(posedge clk) begin
    if (rst) begin
      counter <= 5'b00000;
      block   <= '0;
    end else begin
      case(state)
        IDLE: begin
          counter <= 5'b00000;
          block   <= s_axis_tdata;
        end
        
        UPDATE_BLOCK: begin
          counter <= counter + 1'b1;
          block   <= enc_block;
        end
      endcase
    end
  end

  round round_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(round_s_axis_tdata),
    .s_axis_tvalid(round_s_axis_tvalid),
    .s_axis_tready(round_s_axis_tready),
    .m_axis_tdata(round_m_axis_tdata),
    .m_axis_tvalid(round_m_axis_tvalid),
    .m_axis_tready(round_m_axis_tready),
    .counter(counter),
    .key(key)
  );

  assign round_s_axis_tdata = block[63:48];
  assign round_s_axis_tvalid = (state == ROUND_START);
  assign round_m_axis_tready = 1'b1;

  always @(*) begin
    case(counter)
      5'd0, 5'd1, 5'd2, 5'd3, 5'd4, 5'd5, 5'd6, 5'd7,
      5'd16, 5'd17, 5'd18, 5'd19, 5'd20, 5'd21, 5'd22, 5'd23: begin
        temp_data = round_m_axis_tdata ^ block[15:0] ^ (counter + 1);
        enc_block = {temp_data, round_m_axis_tdata, block[47:32], block[31:16]};
      end
      
      5'd8, 5'd9, 5'd10, 5'd11, 5'd12, 5'd13, 5'd14, 5'd15,
      5'd24, 5'd25, 5'd26, 5'd27, 5'd28, 5'd29, 5'd30, 5'd31: begin
        temp_data = block[63:48] ^ block[47:32] ^ (counter + 1);
        enc_block = {block[15:0], round_m_axis_tdata, temp_data, block[31:16]};
      end
      
      default: enc_block = block;
    endcase
  end

  assign raw_axis_tvalid = (state == WAIT_ROUND) || (state == UPDATE_BLOCK);
  assign m_axis_tdata = block;
  assign m_axis_tvalid = (state == DONE);
  assign s_axis_tready = (state == IDLE);

endmodule
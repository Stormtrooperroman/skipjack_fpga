module skipjack_pipelined (
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

  parameter [1:0] IDLE = 2'b00, ENC = 2'b01, DONE = 2'b10;
  logic [1:0] state = IDLE, next_state;

  logic [4:0]  counter = 5'd0;
  logic [63:0] block, enc_block;
  logic        last_round;
  logic [31:0] round_key = 32'd0;

  logic [15:0] idata;
  logic [15:0] odata;

  logic [15:0] temp_data;

  assign last_round = &counter;

  always @(*) begin
    next_state = state;
    case(state)
      IDLE: if (m_axis_tready) next_state = ENC;
      ENC:  if (last_round)    next_state = DONE;
      DONE: if (s_axis_tvalid) next_state = IDLE;
      default:                 next_state = IDLE;
    endcase
  end

  always @(posedge clk) begin
    if (rst) state <= IDLE;
    else     state <= next_state;
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
        ENC: begin
          counter <= counter + 1'b1;
          block   <= enc_block;
        end
      endcase
    end
  end

  assign idata = block[63:48];

  round round_inst (
    .idata (idata),
    .counter (counter),
    .key   (key),
    .odata (odata)
  );


  always @(*) begin
    if ((counter >= 0 && counter < 8) || (counter >= 16 && counter < 24)) begin

        assign temp_data = odata ^ block[15:0] ^ (counter + 1);
        assign enc_block = {temp_data, odata, block[47:32], block[31:16]};


      end else if ((counter >= 8 && counter < 16) || (counter >= 24 && counter < 32)) begin
        assign temp_data = block[63:48] ^ block[47:32] ^ (counter + 1);
        assign enc_block = {block[15:0], odata, temp_data, block[31:16]};
      end
  end

  assign raw_axis_tvalid = state == ENC;

  assign m_axis_tdata  = block;
  assign m_axis_tvalid = state == DONE;
  assign s_axis_tready = state == IDLE;

endmodule

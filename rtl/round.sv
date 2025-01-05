module round (
  input  logic clk,
  input  logic rst,
  
  input  logic [15:0] s_axis_tdata,
  input  logic        s_axis_tvalid,
  output logic        s_axis_tready,
  
  output logic [15:0] m_axis_tdata,
  output logic        m_axis_tvalid,
  input  logic        m_axis_tready,
  
  input  logic [4:0]  counter,
  input  logic [0:79] key
);
  
  logic [7:0] g[5:0];
  logic [3:0] j[4:0];
  logic [15:0] idata_reg;
  
  typedef enum logic [2:0] {
    IDLE = 3'b000,
    F_BOX_2 = 3'b001,
    F_BOX_3 = 3'b010,
    F_BOX_4 = 3'b011,
    F_BOX_5 = 3'b100,
    DONE = 3'b101
  } state_t;

  state_t state, next_state;
  
  logic [7:0] f_box_s_axis_tdata;
  logic       f_box_s_axis_tvalid;
  logic       f_box_s_axis_tready;
  logic [7:0] f_box_m_axis_tdata;
  logic       f_box_m_axis_tvalid;
  logic       f_box_m_axis_tready;
  
  always @(posedge clk) begin
    if (rst) begin
      state <= IDLE;
    end else begin
      state <= next_state;
    end
  end
  
  always @(*) begin
    next_state = state;
    case (state)
      IDLE: 
        if (s_axis_tvalid && s_axis_tready)
          next_state = F_BOX_2;
      F_BOX_2:
        if (f_box_m_axis_tvalid && f_box_m_axis_tready)
          next_state = F_BOX_3;
      F_BOX_3:
        if (f_box_m_axis_tvalid && f_box_m_axis_tready)
          next_state = F_BOX_4;
      F_BOX_4:
        if (f_box_m_axis_tvalid && f_box_m_axis_tready)
          next_state = F_BOX_5;
      F_BOX_5:
        if (f_box_m_axis_tvalid && f_box_m_axis_tready)
          next_state = DONE;
      DONE:
        if (m_axis_tready && m_axis_tvalid)
          next_state = IDLE;
      default:
        next_state = IDLE;
    endcase
  end
  
  always @(posedge clk) begin
    if (rst) begin
      idata_reg <= '0;
      g[0] <= '0;
      g[1] <= '0;
    end else if (state == IDLE && s_axis_tvalid && s_axis_tready) begin
      idata_reg <= s_axis_tdata;
      g[0] <= s_axis_tdata[15:8];
      g[1] <= s_axis_tdata[7:0];
    end
  end
  
  assign j[0] = (4 * (counter)) % 10;
  
  generate
    genvar i;
    for (i = 1; i < 5; i++) begin : gen_j_loop
      assign j[i] = (j[i-1] + 1) % 10;
    end
  endgenerate
  
  always @(*) begin
    case (state)
      F_BOX_2: f_box_s_axis_tdata = g[1] ^ key[8*j[0] +:8];
      F_BOX_3: f_box_s_axis_tdata = g[2] ^ key[8*j[1] +:8];
      F_BOX_4: f_box_s_axis_tdata = g[3] ^ key[8*j[2] +:8];
      F_BOX_5: f_box_s_axis_tdata = g[4] ^ key[8*j[3] +:8];
      default: f_box_s_axis_tdata = '0;
    endcase
  end

  assign f_box_s_axis_tvalid = (state == F_BOX_2) || (state == F_BOX_3) || 
                            (state == F_BOX_4) || (state == F_BOX_5);
  assign f_box_m_axis_tready = 1'b1;
  
  always @(posedge clk) begin
    if (rst) begin
      g[2] <= '0;
      g[3] <= '0;
      g[4] <= '0;
      g[5] <= '0;
    end else if (f_box_m_axis_tvalid) begin
      case (state)
        F_BOX_2: g[2] <= f_box_m_axis_tdata ^ g[0];
        F_BOX_3: g[3] <= f_box_m_axis_tdata ^ g[1];
        F_BOX_4: g[4] <= f_box_m_axis_tdata ^ g[2];
        F_BOX_5: g[5] <= f_box_m_axis_tdata ^ g[3];
      endcase
    end
  end

  f_box f_box_inst (
    .clk(clk),
    .rst(rst),
    .s_axis_tdata(f_box_s_axis_tdata),
    .s_axis_tvalid(f_box_s_axis_tvalid),
    .s_axis_tready(f_box_s_axis_tready),
    .m_axis_tdata(f_box_m_axis_tdata),
    .m_axis_tvalid(f_box_m_axis_tvalid),
    .m_axis_tready(f_box_m_axis_tready)
  );
  
  assign s_axis_tready = (state == IDLE);
  assign m_axis_tvalid = (state == DONE);
  assign m_axis_tdata = {g[4], g[5]};

endmodule
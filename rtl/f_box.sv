module f_box (
  input  logic clk,
  input  logic rst,
  
  input  logic [7:0] s_axis_tdata,
  input  logic       s_axis_tvalid,
  output logic       s_axis_tready,
  
  output logic [7:0] m_axis_tdata,
  output logic       m_axis_tvalid,
  input  logic       m_axis_tready
);

  typedef enum logic [1:0] {
    IDLE = 2'b00,
    LOOKUP = 2'b01,
    DONE = 2'b10
  } state_t;

  state_t state, next_state;
  logic [7:0] iword_reg;
  logic [7:0] oword_lookup;

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
          next_state = LOOKUP;
      LOOKUP:
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
      iword_reg <= '0;
    end else if (state == IDLE && s_axis_tvalid && s_axis_tready) begin
      iword_reg <= s_axis_tdata;
    end
  end

  always @(*) begin
    case(iword_reg)
      8'h00: oword_lookup = 8'hA3;
      8'h01: oword_lookup = 8'hD7;
      8'h02: oword_lookup = 8'h09;
      8'h03: oword_lookup = 8'h83;
      8'h04: oword_lookup = 8'hF8;
      8'h05: oword_lookup = 8'h48;
      8'h06: oword_lookup = 8'hF6;
      8'h07: oword_lookup = 8'hF4;
      8'h08: oword_lookup = 8'hB3;
      8'h09: oword_lookup = 8'h21;
      8'h0A: oword_lookup = 8'h15;
      8'h0B: oword_lookup = 8'h78;
      8'h0C: oword_lookup = 8'h99;
      8'h0D: oword_lookup = 8'hB1;
      8'h0E: oword_lookup = 8'hAF;
      8'h0F: oword_lookup = 8'hF9;
      8'h10: oword_lookup = 8'hE7;
      8'h11: oword_lookup = 8'h2D;
      8'h12: oword_lookup = 8'h4D;
      8'h13: oword_lookup = 8'h8A;
      8'h14: oword_lookup = 8'hCE;
      8'h15: oword_lookup = 8'h4C;
      8'h16: oword_lookup = 8'hCA;
      8'h17: oword_lookup = 8'h2E;
      8'h18: oword_lookup = 8'h52;
      8'h19: oword_lookup = 8'h95;
      8'h1A: oword_lookup = 8'hD9;
      8'h1B: oword_lookup = 8'h1E;
      8'h1C: oword_lookup = 8'h4E;
      8'h1D: oword_lookup = 8'h38;
      8'h1E: oword_lookup = 8'h44;
      8'h1F: oword_lookup = 8'h28;
      8'h20: oword_lookup = 8'h0A;
      8'h21: oword_lookup = 8'hDF;
      8'h22: oword_lookup = 8'h02;
      8'h23: oword_lookup = 8'hA0;
      8'h24: oword_lookup = 8'h17;
      8'h25: oword_lookup = 8'hF1;
      8'h26: oword_lookup = 8'h60;
      8'h27: oword_lookup = 8'h68;
      8'h28: oword_lookup = 8'h12;
      8'h29: oword_lookup = 8'hB7;
      8'h2A: oword_lookup = 8'h7A;
      8'h2B: oword_lookup = 8'hC3;
      8'h2C: oword_lookup = 8'hC9;
      8'h2D: oword_lookup = 8'hFA;
      8'h2E: oword_lookup = 8'h3D;
      8'h2F: oword_lookup = 8'h53;
      8'h30: oword_lookup = 8'h96;
      8'h31: oword_lookup = 8'h84;
      8'h32: oword_lookup = 8'h6B;
      8'h33: oword_lookup = 8'hBA;
      8'h34: oword_lookup = 8'hF2;
      8'h35: oword_lookup = 8'h63;
      8'h36: oword_lookup = 8'h9A;
      8'h37: oword_lookup = 8'h19;
      8'h38: oword_lookup = 8'h7C;
      8'h39: oword_lookup = 8'hAE;
      8'h3A: oword_lookup = 8'hE5;
      8'h3B: oword_lookup = 8'hF5;
      8'h3C: oword_lookup = 8'hF7;
      8'h3D: oword_lookup = 8'h16;
      8'h3E: oword_lookup = 8'h6A;
      8'h3F: oword_lookup = 8'hA2;
      8'h40: oword_lookup = 8'h39;
      8'h41: oword_lookup = 8'hB6;
      8'h42: oword_lookup = 8'h7B;
      8'h43: oword_lookup = 8'h0F;
      8'h44: oword_lookup = 8'hC1;
      8'h45: oword_lookup = 8'h93;
      8'h46: oword_lookup = 8'h81;
      8'h47: oword_lookup = 8'h1B;
      8'h48: oword_lookup = 8'hEE;
      8'h49: oword_lookup = 8'hB4;
      8'h4A: oword_lookup = 8'h1A;
      8'h4B: oword_lookup = 8'hEA;
      8'h4C: oword_lookup = 8'hD0;
      8'h4D: oword_lookup = 8'h91;
      8'h4E: oword_lookup = 8'h2F;
      8'h4F: oword_lookup = 8'hB8;
      8'h50: oword_lookup = 8'h55;
      8'h51: oword_lookup = 8'hB9;
      8'h52: oword_lookup = 8'hDA;
      8'h53: oword_lookup = 8'h85;
      8'h54: oword_lookup = 8'h3F;
      8'h55: oword_lookup = 8'h41;
      8'h56: oword_lookup = 8'hBF;
      8'h57: oword_lookup = 8'hE0;
      8'h58: oword_lookup = 8'h5A;
      8'h59: oword_lookup = 8'h58;
      8'h5A: oword_lookup = 8'h80;
      8'h5B: oword_lookup = 8'h5F;
      8'h5C: oword_lookup = 8'h66;
      8'h5D: oword_lookup = 8'h0B;
      8'h5E: oword_lookup = 8'hD8;
      8'h5F: oword_lookup = 8'h90;
      8'h60: oword_lookup = 8'h35;
      8'h61: oword_lookup = 8'hD5;
      8'h62: oword_lookup = 8'hC0;
      8'h63: oword_lookup = 8'hA7;
      8'h64: oword_lookup = 8'h33;
      8'h65: oword_lookup = 8'h06;
      8'h66: oword_lookup = 8'h65;
      8'h67: oword_lookup = 8'h69;
      8'h68: oword_lookup = 8'h45;
      8'h69: oword_lookup = 8'h00;
      8'h6A: oword_lookup = 8'h94;
      8'h6B: oword_lookup = 8'h56;
      8'h6C: oword_lookup = 8'h6D;
      8'h6D: oword_lookup = 8'h98;
      8'h6E: oword_lookup = 8'h9B;
      8'h6F: oword_lookup = 8'h76;
      8'h70: oword_lookup = 8'h97;
      8'h71: oword_lookup = 8'hFC;
      8'h72: oword_lookup = 8'hB2;
      8'h73: oword_lookup = 8'hC2;
      8'h74: oword_lookup = 8'hB0;
      8'h75: oword_lookup = 8'hFE;
      8'h76: oword_lookup = 8'hDB;
      8'h77: oword_lookup = 8'h20;
      8'h78: oword_lookup = 8'hE1;
      8'h79: oword_lookup = 8'hEB;
      8'h7A: oword_lookup = 8'hD6;
      8'h7B: oword_lookup = 8'hE4;
      8'h7C: oword_lookup = 8'hDD;
      8'h7D: oword_lookup = 8'h47;
      8'h7E: oword_lookup = 8'h4A;
      8'h7F: oword_lookup = 8'h1D;
      8'h80: oword_lookup = 8'h42;
      8'h81: oword_lookup = 8'hED;
      8'h82: oword_lookup = 8'h9E;
      8'h83: oword_lookup = 8'h6E;
      8'h84: oword_lookup = 8'h49;
      8'h85: oword_lookup = 8'h3C;
      8'h86: oword_lookup = 8'hCD;
      8'h87: oword_lookup = 8'h43;
      8'h88: oword_lookup = 8'h27;
      8'h89: oword_lookup = 8'hD2;
      8'h8A: oword_lookup = 8'h07;
      8'h8B: oword_lookup = 8'hD4;
      8'h8C: oword_lookup = 8'hDE;
      8'h8D: oword_lookup = 8'hC7;
      8'h8E: oword_lookup = 8'h67;
      8'h8F: oword_lookup = 8'h18;
      8'h90: oword_lookup = 8'h89;
      8'h91: oword_lookup = 8'hCB;
      8'h92: oword_lookup = 8'h30;
      8'h93: oword_lookup = 8'h1F;
      8'h94: oword_lookup = 8'h8D;
      8'h95: oword_lookup = 8'hC6;
      8'h96: oword_lookup = 8'h8F;
      8'h97: oword_lookup = 8'hAA;
      8'h98: oword_lookup = 8'hC8;
      8'h99: oword_lookup = 8'h74;
      8'h9A: oword_lookup = 8'hDC;
      8'h9B: oword_lookup = 8'hC9;
      8'h9C: oword_lookup = 8'h5D;
      8'h9D: oword_lookup = 8'h5C;
      8'h9E: oword_lookup = 8'h31;
      8'h9F: oword_lookup = 8'hA4;
      8'hA0: oword_lookup = 8'h70;
      8'hA1: oword_lookup = 8'h88;
      8'hA2: oword_lookup = 8'h61;
      8'hA3: oword_lookup = 8'h2C;
      8'hA4: oword_lookup = 8'h9F;
      8'hA5: oword_lookup = 8'h0D;
      8'hA6: oword_lookup = 8'h2B;
      8'hA7: oword_lookup = 8'h87;
      8'hA8: oword_lookup = 8'h50;
      8'hA9: oword_lookup = 8'h82;
      8'hAA: oword_lookup = 8'h54;
      8'hAB: oword_lookup = 8'h64;
      8'hAC: oword_lookup = 8'h26;
      8'hAD: oword_lookup = 8'h7D;
      8'hAE: oword_lookup = 8'h03;
      8'hAF: oword_lookup = 8'h40;
      8'hB0: oword_lookup = 8'h34;
      8'hB1: oword_lookup = 8'h4B;
      8'hB2: oword_lookup = 8'h1C;
      8'hB3: oword_lookup = 8'h73;
      8'hB4: oword_lookup = 8'hD1;
      8'hB5: oword_lookup = 8'hC4;
      8'hB6: oword_lookup = 8'hFD;
      8'hB7: oword_lookup = 8'h3B;
      8'hB8: oword_lookup = 8'hCC;
      8'hB9: oword_lookup = 8'hFB;
      8'hBA: oword_lookup = 8'h7F;
      8'hBB: oword_lookup = 8'hAB;
      8'hBC: oword_lookup = 8'hE6;
      8'hBD: oword_lookup = 8'h3E;
      8'hBE: oword_lookup = 8'h5B;
      8'hBF: oword_lookup = 8'hA5;
      8'hC0: oword_lookup = 8'hAD;
      8'hC1: oword_lookup = 8'h04;
      8'hC2: oword_lookup = 8'h23;
      8'hC3: oword_lookup = 8'h9C;
      8'hC4: oword_lookup = 8'h14;
      8'hC5: oword_lookup = 8'h51;
      8'hC6: oword_lookup = 8'h22;
      8'hC7: oword_lookup = 8'hF0;
      8'hC8: oword_lookup = 8'h29;
      8'hC9: oword_lookup = 8'h79;
      8'hCA: oword_lookup = 8'h71;
      8'hCB: oword_lookup = 8'h7E;
      8'hCC: oword_lookup = 8'hFF;
      8'hCD: oword_lookup = 8'h8C;
      8'hCE: oword_lookup = 8'h0E;
      8'hCF: oword_lookup = 8'hE2;
      8'hD0: oword_lookup = 8'h0C;
      8'hD1: oword_lookup = 8'hEF;
      8'hD2: oword_lookup = 8'hBC;
      8'hD3: oword_lookup = 8'h72;
      8'hD4: oword_lookup = 8'h75;
      8'hD5: oword_lookup = 8'h6F;
      8'hD6: oword_lookup = 8'h37;
      8'hD7: oword_lookup = 8'hA1;
      8'hD8: oword_lookup = 8'hEC;
      8'hD9: oword_lookup = 8'hD3;
      8'hDA: oword_lookup = 8'h8E;
      8'hDB: oword_lookup = 8'h62;
      8'hDC: oword_lookup = 8'h8B;
      8'hDD: oword_lookup = 8'h86;
      8'hDE: oword_lookup = 8'h10;
      8'hDF: oword_lookup = 8'hE8;
      8'hE0: oword_lookup = 8'h08;
      8'hE1: oword_lookup = 8'h77;
      8'hE2: oword_lookup = 8'h11;
      8'hE3: oword_lookup = 8'hBE;
      8'hE4: oword_lookup = 8'h92;
      8'hE5: oword_lookup = 8'h4F;
      8'hE6: oword_lookup = 8'h24;
      8'hE7: oword_lookup = 8'hC5;
      8'hE8: oword_lookup = 8'h32;
      8'hE9: oword_lookup = 8'h36;
      8'hEA: oword_lookup = 8'h9D;
      8'hEB: oword_lookup = 8'hCF;
      8'hEC: oword_lookup = 8'hF3;
      8'hED: oword_lookup = 8'hA6;
      8'hEE: oword_lookup = 8'hBB;
      8'hEF: oword_lookup = 8'hAC;
      8'hF0: oword_lookup = 8'h5E;
      8'hF1: oword_lookup = 8'h6C;
      8'hF2: oword_lookup = 8'hA9;
      8'hF3: oword_lookup = 8'h13;
      8'hF4: oword_lookup = 8'h57;
      8'hF5: oword_lookup = 8'h25;
      8'hF6: oword_lookup = 8'hB5;
      8'hF7: oword_lookup = 8'hE3;
      8'hF8: oword_lookup = 8'hBD;
      8'hF9: oword_lookup = 8'hA8;
      8'hFA: oword_lookup = 8'h3A;
      8'hFB: oword_lookup = 8'h01;
      8'hFC: oword_lookup = 8'h05;
      8'hFD: oword_lookup = 8'h59;
      8'hFE: oword_lookup = 8'h2A;
      8'hFF: oword_lookup = 8'h46;
      default: oword_lookup = 8'h00;
    endcase
  end

  assign s_axis_tready = (state == IDLE);
  assign m_axis_tvalid = (state == DONE);
  assign m_axis_tdata = oword_lookup;

endmodule
module top (
  input rst_n,
  input clk,
  input rxd,

  output txd
);

  logic [0:79] KEY = 80'h0123456789abcdef0123;

  logic rst;
  logic pll_clk;

  logic [7:0]   s_uart_tdata;
  logic         s_uart_tvalid;
  logic         s_uart_tready;

  logic [63:0]  s_cipher_tdata;
  logic         s_cipher_tvalid;
  logic         s_cipher_tready;

  logic [7:0]   m_uart_tdata;
  logic         m_uart_tvalid;
  logic         m_uart_tready;

  logic [63:0]  m_cipher_tdata;
  logic         m_cipher_tvalid;
  logic         m_cipher_tready;

  parameter STAGES=2;


  synchronizer #(
    .STAGES(STAGES)
  ) my_synchronizer_instance (
    .clk(clk),

    .d(rst_n),
    .q(rst)
  );

  Gowin_rPLL your_instance_name(
    .clkout(pll_clk), //output clkout
    .reset(rst), //input reset
    .clkin(clk) //input clkin
  );


  uart uart_inst (
    .clk(pll_clk),
    .rst(rst),
    .rxd(rxd),
    .txd(txd),
    .s_axis_tdata(s_uart_tdata),
    .s_axis_tvalid(s_uart_tvalid),
    .s_axis_tready(s_uart_tready),
    .m_axis_tdata(m_uart_tdata),
    .m_axis_tvalid(m_uart_tvalid),
    .m_axis_tready(m_uart_tready),
    .prescale(100_000_000 / (115200 * 8))
  );

  skipjack_iterative encryption (
    .rst(rst),
    .clk(pll_clk),
    .key(KEY),
    .s_axis_tdata(s_cipher_tdata),
    .s_axis_tvalid(s_cipher_tvalid),
    .s_axis_tready(s_cipher_tready),
    .m_axis_tdata(m_cipher_tdata),
    .m_axis_tvalid(m_cipher_tvalid),
    .m_axis_tready(m_cipher_tready)
  );


  axis_fifo_adapter #(
    .DEPTH(16),
    .S_DATA_WIDTH(8),
    .M_DATA_WIDTH(64),
    .USER_ENABLE(0),
    .RAM_PIPELINE(1)
  ) fifo_adapter_8_to_64 (
    .clk(pll_clk),
    .rst(rst),
    .s_axis_tdata(m_uart_tdata),
    .s_axis_tvalid(m_uart_tvalid),
    .s_axis_tready(m_uart_tready),
    .m_axis_tdata(s_cipher_tdata),
    .m_axis_tvalid(s_cipher_tvalid),
    .m_axis_tready(s_cipher_tready)
  );

  axis_fifo_adapter #(
    .DEPTH(16),
    .S_DATA_WIDTH(64),
    .M_DATA_WIDTH(8),
    .USER_ENABLE(0),
    .RAM_PIPELINE(1)
  ) fifo_adapter_64_to_8 (
    .clk(pll_clk),
    .rst(rst),
    .s_axis_tdata(m_cipher_tdata),
    .s_axis_tvalid(m_cipher_tvalid),
    .s_axis_tready(m_cipher_tready),
    .s_axis_tkeep('1),
    .m_axis_tdata(s_uart_tdata),
    .m_axis_tvalid(s_uart_tvalid),
    .m_axis_tready(s_uart_tready)
  );

endmodule

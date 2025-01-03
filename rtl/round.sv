module round (
  input  logic [15:0] idata,
  input  logic [4:0] counter,
  input  logic [0:79] key,
  output logic [15:0] odata
);
  logic [7:0] g[5:0];
  logic [3:0] j[4:0];

  assign g[0] = idata[15:8];
  assign g[1] = idata[7:0];

  assign j[0] = (4 * (counter)) % 10;
  generate
    genvar i;

    for (i = 2; i < 6; i++) begin : gen_loop
      wire [7:0] substituted;
      f_box f_box_inst (
        .iword(g[i - 1] ^ key[8*j[i - 2] +:8]),
        .oword(substituted)
      );

      assign g[i] = substituted ^ g[i - 2];
      assign j[i-1] = (j[i-2] + 1) % 10;
    end
  endgenerate

  assign odata = {g[4], g[5]};

endmodule

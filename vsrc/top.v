module top(
  input a,
  input b,
  input btnc,
  input clk,
  input rst,
  output f,
  output down,
  output reg [15:0] led
);
  
  assign f = a ^ b;
  assign down = btnc;

  light _light(
    .clk(clk),
    .rst(rst),
    .led(led)
  );

endmodule

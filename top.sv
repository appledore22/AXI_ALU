module top(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  input clk;
  input reset;
  
  // write data channel
  input reg [9:0] wdata;
  input reg wvalid;
  output wready;	
  
  // read data channel
  output rvalid;
  output [9:0] rdata;
  input reg rready;
  
  wire fifo_1_wready;
  wire fifo_1_rvalid;
  wire [9:0] fifo_1_rdata;
  
  wire [9:0] alu_wdata;
  wire alu_wvalid;
  wire alu_rready;

  wire fifo2_wready;
  
  axi_fifo fifo1(clk,reset,wdata,wvalid,wready,fifo_1_rvalid,fifo_1_rdata,alu_rready);
  axi_alu alu(clk,reset,alu_wdata,alu_wvalid,fifo2_wready,fifo_1_rvalid,fifo_1_rdata,alu_rready);
  axi_fifo fifo2(clk,reset,alu_wdata,alu_wvalid,fifo2_wready,rvalid,rdata,rready);
  
endmodule

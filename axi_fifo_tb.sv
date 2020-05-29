// Code your testbench here
// or browse Examples
module test();
  reg clk;
  reg reset;
  
  // write data channel
  reg [7:0] wdata;
  reg wvalid;
  wire wready;	
  
  // read data channel
  reg rvalid;
  wire [8:0] rdata;
  wire rready;
  
  axi_fifo af1(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
  initial 
    begin
      clk = 0;
      reset = 1;
      #10;
      reset = 0;
      
      fork
        begin
          repeat(4)
            begin
              @(negedge clk);
              wait(wready == 1);
              @(negedge clk);
              wvalid = 1;
              wdata = $random;
            end
        end
        begin
          repeat(4)
            begin
              @(negedge clk);
              wait(rready == 1);
              @(negedge clk);
              rvalid = 1;
              wdata = $random;
            end
        end
      join
    end
  
  always #5 clk = ~clk;
  
endmodule

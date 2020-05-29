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
  wire rvalid;
  wire [7:0] rdata;
  reg rready;
  
  bit [8:0] data_stored [$];
  
  axi_fifo af1(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
  initial 
    begin
       $dumpfile("test.vcd");
    $dumpvars;

      clk = 0;
      reset = 1;
      #10;
      reset = 0;
      rready = 0;
      
      fork
        begin
          repeat(10)
            begin
              wait(wready == 1);
              @(negedge clk);
              wvalid = 1;
              wdata = $random;
            end
        end
        begin
          #40;
          repeat(3)
            begin
              @(posedge clk);
              wait(rvalid == 1);
              rready = 1;
              @(posedge clk);
              data_stored.push_back(rdata);
            end
          rready = 0;
        end
      join_none
      
      #200;
      $finish;
    end
  
  always #5 clk = ~clk;
  
endmodule

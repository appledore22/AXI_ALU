// Code your testbench here
// or browse Examples
module test();
  reg clk;
  reg reset;
  
  // write data channel
  wire [9:0] wdata;
  wire wvalid;
  reg wready;	
  
  // read data channel
  reg rvalid;
  reg [9:0] rdata;
  wire rready;
  
  
  axi_alu alu1(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
  initial 
    begin
   		$dumpfile("test.vcd");
    	$dumpvars;
      	clk = 0;
      	reset = 1;
      	#10;
      	reset = 0;
      	wready = 1;
      	rvalid = 0;
      	rdata = 0;
      	#5;
      fork
        repeat(10)
        begin
          @(negedge clk);
          wait(rready == 1);
          @(negedge clk);
          rdata = $random;
          rvalid = 1;          
        end
        begin
          #190;
          wready = 0;
        end
      join_none
      rvalid = 0;
      #300;
      $finish;
      	
    end
  
  always #5 clk = ~clk;
  
endmodule

module test();
  reg clk;
  reg reset;
  
  // write data channel
  reg [9:0] wdata;
  reg wvalid;
  wire wready;	
  
  // read data channel
  wire rvalid;
  wire [9:0] rdata;
  reg rready;
  
    bit [8:0] data_stored [$];
  
  top t1(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
  initial
    begin
           $dumpfile("test.vcd");
    $dumpvars;

      clk = 0;
      reset = 1;
      #10;
      reset = 0;
      
       
      fork
        begin
          repeat(10)
            begin
              wait(wready == 1);
              @(negedge clk);
              wvalid = 1;
              wdata = $random;
            end
          	wvalid = 0;
        end
        begin
          #40;
          repeat(20)
            begin
              @(posedge clk);
              wait(rvalid == 1);
              @(negedge clk);
              rready = 1;
              @(negedge clk);
              rready = 0;
              data_stored.push_back(rdata);
            end
        end
      join_none
      
      #600;
      $display("%p",data_stored);
      $finish;
    end
  
    always #5 clk = ~clk;
endmodule

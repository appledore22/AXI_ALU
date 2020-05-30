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
  bit [8:0] data_computed [$];
  
  reg [9:0] data;

  
  top t1(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
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
          repeat(40)
            begin
              wait(wready == 1);
              @(negedge clk);
              wvalid = 1;
              wdata = $random();
              data_stored.push_back(wdata);

            end
          	wvalid = 0;
        end
        begin
          #40;
          repeat(6)
            begin
              @(posedge clk);
              wait(rvalid == 1);
              @(negedge clk);
              rready = 1;
              @(posedge clk);
              #3;
              rready = 0;
              data_computed.push_back(rdata);
            end
        end
      join_none
      
      #600;
      $display("%p",data_stored);
      $display("%p",data_computed);
      
      repeat(data_computed.size())
        begin
         	data_stored.pop(data);
          case(data[9:8])
            0:if()
             
          
        end

      $finish;
    end
  
    always #5 clk = ~clk;
endmodule

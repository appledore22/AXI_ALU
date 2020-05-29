module axi_alu(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
  input clk;
  input reset;
  
  // write data channel
  output reg [9:0] wdata;
  output reg wvalid;
  input wready;	
  
  // read data channel
  input rvalid;
  input [9:0] rdata;
  output reg rready;
  
  // Use of internal registers is done so that when certain operation taskes multiple cycles to execute 
  // the final result will use the present operands to calcluate the result. Store the operands into a latch
  // and then using it for operation ensures that correct operation is performed on correct operands
  
  parameter cycles = 4;
  
  reg [3:0] reg1;	// operand1
  reg [3:0] reg2;	// operand2
  reg [3:0] reg3;	// operation
  reg [9:0] reg4;	// result
  reg [4:0] count;	
  
  assign wdata = reg4;
  
  always@(posedge clk)
    begin
      if(reset)
        begin
          wvalid <= 0;
          rready <= 1;
          reg1 <= 0;
          reg2 <= 0;
          reg3 <= 0;
          reg4 <= 0;
          count <= 0;
        end
      else
        begin
          if(rvalid && rready && wready)
            begin
              	reg1 <= rdata[3:0];
              	reg2 <= rdata[7:4];
              	reg3 <= rdata[9:8];
              	rready <= 0;
              	wvalid <= 0;
            end
          else
            if(wready)
              begin
                case(reg3)
                  0:begin
                    	reg4 <= reg1+reg2;
                    	wvalid <= 1;
	                    rready <= 1;

                  end
                  1:begin
                    	reg4 <= reg1-reg2;
                    	wvalid <= 1;                                        	
                    	rready <= 1;
                  end
                  2:begin
                    if(count == cycles-1)
                      begin
                        reg4 <= reg1*reg2;
                        wvalid <= 1;                                        	
                        rready <= 1;
                        count = 0;
                      end
                    else
                      begin
                        count = count + 1;
                        wvalid <= 0;
                    	rready <= 0;
                      end
                  end
                  3:begin
                    	reg4 <= reg1^reg2;
                    	wvalid <= 1;                                        	
                    	rready <= 1;
                  end
                endcase
              end
          	else
              	rready <= 0;
              end
    end
endmodule

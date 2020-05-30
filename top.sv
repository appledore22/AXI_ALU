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


module axi_fifo(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
  input clk;
  input reset;
  
  // write data channel
  input [9:0] wdata;
  input wvalid;
  output reg wready;	
  
  // read data channel
  output reg rvalid;
  output reg [9:0] rdata;
  input rready;
  
  reg full;
  reg empty;
  
  reg [9:0] mem [8];
  reg [2:0] wptr;
  reg [2:0] rptr;
  
  assign wready = ~full;	// fifo not full. So ready to take write data
  assign rvalid = ~empty;	// fifo not empty. So output data is valid until fifo not empty to send data
  
  always@(posedge clk)
    begin
      if(reset)
        begin
          wptr <= 0;
          rptr <= 0;
          full <= 0;
          empty <= 1;
        end
      else
        begin
          if(wvalid && wready)      // i.e when valid data and not full
              begin
                mem[wptr] <= wdata;
                empty <= 0;
                if(wptr == (rptr-1) || (wptr == 7 && rptr == 0))  // when wptr is 1 less the rptr this means fifo is full. When no read occurs and wptr reaches end value that means fifo is full
                	wptr <= wptr;
                else
                  wptr <= wptr +1;
              end          	
          	if(wptr == (rptr-1) || (wptr == 7 && rptr == 0))
              begin
              	full <= 1;
                empty <= 0;                
              end
          if(rptr == wptr)  // Initial condition when both are 0 so empty is 1 and full is 0
              begin
               empty <= 1;
               full  <= 0;
              end         	
        end      
    end 
  
  always@(negedge clk)  // negedge is uesd to avoid confusion in waveforms. posedge can be used as well.
    begin
      if(!empty)
              begin
                rdata <= mem[rptr];
                if(rready)
                	rptr <= rptr + 1;
              end
          
    end
  
endmodule

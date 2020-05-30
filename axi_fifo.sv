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

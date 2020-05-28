// Code your design here
module axi_fifo(clk,reset,wdata,wvalid,wready,rvalid,rdata,rready);
  
  input clk;
  input reset;
  
  // write data channel
  input [7:0] wdata;
  input wvalid;
  output reg wready;	
  
  // read data channel
  input rvalid;
  output reg [8:0] rdata;
  output reg rready;
  
  reg full;
  reg empty;
  
  reg [7:0] mem [8];
  reg [2:0] wptr;
  reg [2:0] rptr;
  
  assign wready = ~full;	// fifo not full. So ready to take write data
  assign rready = ~empty;	// fifo not empty. So ready to send data
  
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
            if(wvalid && wready)
              begin
                mem[wptr] <= wdata;
                wptr <= wptr + 1;
              end          	
          	if(wptr == (rptr-1))
              	full = 1;
          	
            if(rvalid && rready)
              begin
                rdata <= mem[rptr];
                rptr <= rptr + 1;
              end
            if(rptr == 0)
               empty = 1;
        end      
    end 
  
endmodule

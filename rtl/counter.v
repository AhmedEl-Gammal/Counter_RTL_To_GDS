module counter(
input rst_n,clk , 
output reg [2:0] count , 
output flag
); 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n) count <= 0; 
	else count <= count +1;
end 

assign flag = (count == 3'b101) ? 1'b1 : 1'b0 ;
 
endmodule 



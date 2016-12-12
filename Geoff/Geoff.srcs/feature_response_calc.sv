module feature_response_calc (
		input  logic	[7:0][16:0] feature_block_sum, //first index is the block, top left to 
																						 //bottom right, going left to right
		input  logic	[7:0][1:0] signs, //ith bit is the sign of feature_block[i], 2 => -1
		input  logic [9:0] weight,
		output logic [16:0] result);

	assign result =	
		(	((signs[0]==1)?(feature_block_sum[0]):((signs[0]==2)?(~feature_block_sum[0]+17'd1):(0))) + 
			((signs[1]==1)?(feature_block_sum[1]):((signs[1]==2)?(~feature_block_sum[1]+17'd1):(0))) +
			((signs[2]==1)?(feature_block_sum[2]):((signs[2]==2)?(~feature_block_sum[2]+17'd1):(0))) +
			((signs[3]==1)?(feature_block_sum[3]):((signs[3]==2)?(~feature_block_sum[3]+17'd1):(0)))/* +
			((signs[4]==1)?(feature_block_sum[4]):((signs[4]==2)?(~feature_block_sum[4]+8'd1):(0))) +
			((signs[5]==1)?(feature_block_sum[5]):((signs[5]==2)?(~feature_block_sum[5]+8'd1):(0))) +
			((signs[6]==1)?(feature_block_sum[6]):((signs[6]==2)?(~feature_block_sum[6]+8'd1):(0))) +
			((signs[7]==1)?(feature_block_sum[7]):((signs[7]==2)?(~feature_block_sum[7]+8'd1):(0)))*/);
			//* weight;

endmodule 

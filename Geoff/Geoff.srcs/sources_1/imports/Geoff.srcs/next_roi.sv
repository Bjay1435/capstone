module next_roi 
	(	input  logic [9:0]	roi_hor_index,
		input  logic [8:0]	roi_vert_index,
		input  logic [8:0]	roi_side_length,
		input  logic 		roi_passed, was_final_stage,
		output logic [9:0]	next_roi_hor_index,
		output logic [8:0]	next_roi_vert_index,
		output logic [8:0]	next_roi_side_length);

	logic [8:0] max_roi_size;
	assign max_roi_size = 91;
	logic [8:0] shift_factor, size_increase_factor;
	assign shift_factor = 10;
	assign size_increase_factor = 10;
	always_comb begin
		if (was_final_stage || roi_passed) begin
			//ROI is at the right side of the image
			if (roi_hor_index+roi_side_length >= 320) begin
				next_roi_hor_index = 0;
				//ROI is also at the bottom corner of the image
				if (roi_vert_index+roi_side_length >= 240) begin
					next_roi_vert_index = 0;
					if (roi_side_length > max_roi_size) begin
					   next_roi_side_length = roi_side_length;
					end
					else begin
					   next_roi_side_length = roi_side_length+size_increase_factor;
					end
				end
				//ROI is at the right side but no the bottom
				else begin
					next_roi_vert_index = roi_vert_index+shift_factor;
					next_roi_side_length = roi_side_length; 
				end
			end
			//ROI is anywhere else
			else begin
				next_roi_hor_index = roi_hor_index+shift_factor;
				next_roi_vert_index = roi_vert_index;
				next_roi_side_length = roi_side_length;
			end
		end
		else begin
			next_roi_hor_index = roi_hor_index;
			next_roi_vert_index = roi_vert_index;
			next_roi_side_length = roi_side_length;
		end
	end

endmodule

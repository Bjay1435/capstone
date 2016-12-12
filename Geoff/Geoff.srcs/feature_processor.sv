module feature_processor
	(	input  logic clk , rst,
		input  logic start_processor,
		//Feature data
		input  feature features [7:0],
		input  logic [3:0] stage_number, //which stage we're on, up to 16
		input  [2:0] num_features, //allows for up to 8 features
		//ROI
		input  logic [8:0] roi_row_index,
		input  logic [9:0] roi_col_index,
		input  logic [8:0] roi_side_length,
		//feature weights
		input  logic [9:0] weight [7:0],
		//Memory Interface
		//input  logic [3:0] integral_pixel_value,
		input  logic pixel_value_valid,
	 	//output logic [8:0] row_index,
		//output logic [9:0] col_index,
		output logic mem_indices_valid,
		//Output Signals
		output ROI roi_out,
		output logic passed, 
		output logic processor_done,
		output logic [3:0] stage_number_out,
		input  logic image_done, live);
		//output logic [2:0] current_feature2,
		//output logic [1:0] fp_cs,
		//output logic frs , strtd);
		//output logic [9:0] wfr,
		//output logic [1:0][3:0] bv,
		//output logic [3:0][3:0] iv, iv2,
		//output logic [9:0] rc,
		//output logic [2:0] cf1,
		//output logic [3:0] ipv,rpv,
		//output logic [19:0] addrb,
		//output logic [255:0] doutb);

	//******************** INITIAL SETUP *********************//
	//memory interface, runs at the beginning to get all of the 
	//integral values of a feature
	typedef enum logic [2:0] {waiting=3'd0 , start=3'd1 , running=3'd2 , last_read=3'd3 , last_read2=3'd4 , last_read3=3'd5} state;
	logic [2:0] current_state , next_state, reg_state, reg_state2, reg_state3;
	logic [9:0] read_count;
	logic [2:0] current_feature; //indexes into the feature attributes to get
															 //the current one
															 
    //assign rc = reg_read_count;
    //assign fp_cs = current_state;
    //assign frs = feature_read_start;
    //assign strtd = started;
    //assign cf1 = current_feature;
    logic [9:0] col_index;
    logic [8:0] row_index;
    
	logic processing_start;
	logic feature_read_start , image_reading_done;
	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			current_feature <= 0;
			feature_read_start <= 0;
			image_reading_done <= 0;
			mem_indices_valid <= 0;
		end
		else if (start_processor) begin
			current_feature <= 0;
			feature_read_start <= 1;
			image_reading_done <= 0;
			mem_indices_valid <= 0;
		end
		else if (current_state == start) begin
			feature_read_start <= 0;
			mem_indices_valid <= 1;
		end
		else if (current_state == last_read3) begin
			if (current_feature >= num_features-1) begin
				image_reading_done <= 1;
				mem_indices_valid <= 0;
			end
			else begin
				current_feature <= current_feature + 1;
				feature_read_start <= 1;
				mem_indices_valid <= 0;
			end
		end
		else if (processing_start) begin
			image_reading_done <= 0;
		end
	end

	//state register
	always_ff @(posedge clk, negedge rst) begin
		if (~rst || start_processor) begin
			current_state <= waiting;
			read_count <= 0;
		end
		else if (current_state == running) begin
			read_count <= read_count + 1;
			current_state <= next_state;
		end
		else if (current_state == waiting) begin
			read_count <= 0;
			current_state <= next_state;
		end
		else if (current_state == last_read3) begin
		  read_count <= 0;
		  current_state <= next_state;
		end
		else current_state <= next_state;
	end

	logic [9:0] number_of_corners,number_of_blocks;
	assign number_of_blocks = features[current_feature].hor_block_dimensions*
														features[current_feature].vert_block_dimensions;
	assign number_of_corners = number_of_blocks*4;	
	//variable size probably won't synthesize, find max value
	logic [7:0][19:0][3:0][16:0] integral_values; 
		//[7:0] : one for each feature
		//[number_of_blocks-1:0] : number of blocks
		//[3:0] : 4 corners, TL, TR, BL, BR
		//[3:0] : integral pixel values

	logic started;
	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			started <= 0;
		end
		else if (start_processor) begin
			started <= 1;
		end
		else if (processor_done && image_reading_done) begin
			started <= 0;
		end
	end

	//next state logic
	always_comb begin
		next_state = current_state;
		if (started && feature_read_start && current_state == waiting) begin
			next_state = start;
		end
		else if (current_state == start) begin
			next_state = running;
		end
		else if (current_state == running && 
				 read_count >= number_of_corners-2) begin
			next_state = last_read;
		end
		else if (current_state == last_read) begin
			next_state = last_read2;
		end
		else if (current_state == last_read2) begin
            next_state = last_read3;
        end
		else if (current_state == last_read3) begin
		      next_state = waiting;
		end
	end
	
	//get the pixel dimensions of the blocks
    logic [8:0] hor_block_size , vert_block_size;
    assign hor_block_size = features[current_feature].feature_width/
                                                    features[current_feature].hor_block_dimensions;
    assign vert_block_size = features[current_feature].feature_height/
                                                     features[current_feature].vert_block_dimensions;

    //  0----1
    //  |    |
    //  2----3

    //assign memory addresses
    always_comb begin
        row_index = 0;
        col_index = 0;
        if (current_state != waiting) begin
            row_index = roi_row_index + //roi offset
                        features[current_feature].feature_vert_index + //starting point
                        read_count[1]*vert_block_size + //moves to bottom of the block
                        ((read_count/4)/
                        features[current_feature].hor_block_dimensions)*
                        vert_block_size; //moves down a row
            col_index = roi_col_index +
                        features[current_feature].feature_hor_index +
                        read_count[0]*hor_block_size +
                        ((read_count/4)%
                        features[current_feature].hor_block_dimensions)*
                        hor_block_size;
        end
    end
	
	logic [8:0] roi_row;
	assign roi_row = roi_row_index;
	logic [9:0] roi_col;
	assign roi_col = roi_col_index;
	logic [16:0] addr;
	logic [19:0] dout, doutb, reg_dout;
	logic [16:0] integral_pixel_value;
	assign addr = ({7'd0,col_index}/2/*+19'd12*/) + (({7'd0,row_index}/2/*+19'd10*/)*17'd320);
	assign doutb = dout;
	logic [16:0] reg_addr, reg_addr2, reg_addr3;
	blk_mem_gen_2(.clka(clk) , .addra(reg_addr) , .douta(dout));
	assign integral_pixel_value = reg_dout&20'h1f_ff_ff;

	
	logic [16:0] reg_pix_val;
	logic [9:0] reg_read_count, reg_read_count2, reg_read_count3;
	logic [2:0] reg_feature, reg_feature2, reg_feature3;
	always_ff @(posedge clk, negedge rst) begin
	   if (~rst) begin
	       reg_read_count <= 10'd0;
	       reg_pix_val <= 8'd0;
	       reg_dout <= 0;
           reg_addr <= 0;
           reg_addr2 <= 0;
           reg_addr3 <= 0;
           reg_state <= 0;
           reg_state2 <= 0;
           reg_state3 <= 0;
           reg_feature <= 0;
           reg_feature2 <= 0;
           reg_feature3 <= 0;
	   end
	   else if (start_processor || ~started) begin
	       reg_read_count <= 10'd0;
	       reg_pix_val <= 8'd0;
	       reg_dout <= 0;
           reg_addr <= 0;
           reg_addr2 <= 0;
           reg_addr3 <= 0;
           reg_state <= 0;
           reg_state2 <= 0;
           reg_state3 <= 0;
           reg_feature <= 0;
           reg_feature2 <= 0;
           reg_feature3 <= 0;
	   end
	   else begin
           reg_dout <= dout;
           reg_addr <= addr;
           reg_addr2 <= reg_addr;
           reg_addr3 <= reg_addr2;
           reg_state <= current_state;
           reg_state2 <= reg_state;
           reg_state3 <= reg_state2;
           reg_feature <= current_feature;
           reg_feature2 <= reg_feature;
           reg_feature3 <= reg_feature2;
	       reg_read_count <= read_count;
	       reg_read_count2 <= reg_read_count;
	       reg_read_count3 <= reg_read_count2;
	   end
	end

	//integral values register
	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			integral_values <= {8{ {20{ {4{ 17'd0 }} }} }};
		end
		else if (start_processor || ~started) begin
		  integral_values <= {8{ {20{ {4{ 17'd0 }} }} }};
		end
		else if (reg_state3 != waiting && reg_state3 != start) begin
		    integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]] <= integral_pixel_value;
			/*integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][0] <= (integral_pixel_value[0]); 
			integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][1] <= (integral_pixel_value[1]); 
			integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][2] <= (integral_pixel_value[2]); 
			integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][3] <= (integral_pixel_value[3]); 
			integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][4] <= (integral_pixel_value[4]); 
            integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][5] <= (integral_pixel_value[5]); 
            integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][6] <= (integral_pixel_value[6]); 
            integral_values[reg_feature3][reg_read_count3[9:2]][reg_read_count3[1:0]][7] <= (integral_pixel_value[7]); */
		end
	end



	//******************** PROCESSING ********************//

	logic done, reg_done, failed;
	logic [9:0] number_of_blocks2, reg_num_blocks;
	logic [2:0] current_feature2;
	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			processing_start <= 0;
			current_feature2 <= 0;
			processor_done <= 0;
		end
		else if (start_processor || ~started) begin
            processing_start <= 0;
            current_feature2 <= 0;
            processor_done <= 0;
        end
		else if (current_feature2 >= num_features) begin
			processor_done <= 1;
			current_feature2 <= 0;
		end
		else if (image_reading_done) begin
			processing_start <= 1;
		end
		else if (processing_start) begin
			processing_start <= 0;
		end
		else if (failed) begin
			processor_done <= 1;
		end
		else if (reg_done) begin
			if ({1'd0,current_feature2} <= {1'd0,num_features-1}) begin
				current_feature2 <= current_feature2 + 1;
				processing_start <= 1;
			end
			else begin
				processor_done <= 1;
			end	
		end
	end

	assign number_of_blocks2 = features[current_feature2].hor_block_dimensions*
							   features[current_feature2].vert_block_dimensions;
	
	//Condense the integral values down to the value for each block
	//need to find max # of blocks
	logic [7:0][7:0][16:0] block_values;
	logic [7:0][9:0] count;
	logic copying;
	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			count <= {8{10'd0}};	
			done <= 0;
			reg_done <= 0;
			reg_num_blocks <= 0;
			copying <= 0;
		end
		else if (start_processor || ~started) begin
            count <= {8{10'd0}};    
            done <= 0;
            reg_done <= 0;
            reg_num_blocks <= 0;
            copying <= 0;
        end
		else if (failed || processor_done) begin
			done <= 0;
			reg_done <= 0;
			reg_num_blocks <= number_of_blocks2;
			copying <= 0;
		end
		else if (reg_done) begin
		    reg_done <= 0;
		    reg_num_blocks <= number_of_blocks2;
		end
		else if (done) begin
			done <= 0;
			reg_done <= 1;
			reg_num_blocks <= number_of_blocks2;
		end
		else if (count[current_feature2] > reg_num_blocks+2) begin
			copying <= 0;
			done <= 1;
			reg_num_blocks <= number_of_blocks2;
		end
		else if (processing_start || copying) begin
			copying <= 1;
			count[current_feature2] <= count[current_feature2] + 1;
			reg_num_blocks <= number_of_blocks2;
		end
	end

    logic [16:0] block_corner0, block_corner1, block_corner2, block_corner3;
    always_ff @(posedge clk) begin
        block_corner0 <= integral_values[current_feature2][count[current_feature2]-1][0];
        block_corner1 <= integral_values[current_feature2][count[current_feature2]-1][1];
        block_corner2 <= integral_values[current_feature2][count[current_feature2]-1][2];
        block_corner3 <= integral_values[current_feature2][count[current_feature2]-1][3];
    end

    logic [16:0] temp_bv;
    assign temp_bv = 
        integral_values[current_feature2][count[current_feature2]-1][0] - 
        integral_values[current_feature2][count[current_feature2]-1][1] -
        integral_values[current_feature2][count[current_feature2]-1][2] + 
        integral_values[current_feature2][count[current_feature2]-1][3] ;
        
    logic [16:0] reg_bv;
    logic reg_copying, reg_copying2;
    logic [7:0][9:0] reg_count, reg_count2;
    logic [2:0] reg_cf, reg_cf2;
    always_ff @(posedge clk, negedge rst) begin
        if (~rst) begin
            reg_bv <= 0;
            reg_copying <= 0;
            reg_copying2 <= 0;
            reg_cf <= 0;
            reg_cf2 <= 0;
            reg_count <= 0;
            reg_count2 <= 0;
        end
        else if (start_processor || ~started || processor_done) begin
            reg_bv <= 0;
            reg_copying <= 0;
            reg_copying2 <= 0;
            reg_cf <= 0;
            reg_cf2 <= 0;
            reg_count <= 0;
            reg_count2 <= 0;
        end
        else begin
            reg_bv <= block_corner0 - block_corner1 - block_corner2 + block_corner3;//temp_bv;
            reg_copying <= copying;
            reg_copying2 <= reg_copying;
            reg_cf <= current_feature2;
            reg_cf2 <= reg_cf;
            reg_count <= count;
            reg_count2 <= reg_count;
        end
    end
        
	always_ff @(posedge clk, negedge rst) begin 
		if (~rst) begin
			block_values <= {8{ {8{17'd0}} }};
		end
		else if (reg_copying2) begin
			block_values[reg_cf2][reg_count2[reg_cf2]-1] <= reg_bv;
                //  integral_values[current_feature2][count[current_feature2]-1][0] + 
                //(~integral_values[current_feature2][count[current_feature2]-1][1])+8'd1 +
                //(~integral_values[current_feature2][count[current_feature2]-1][2])+8'd1 + 
                //  integral_values[current_feature2][count[current_feature2]-1][3] ;
		end
		else block_values<=block_values;
	end

	//pass the block values and the feature through the feature_response_calc
	logic [16:0] weighted_feature_result, reg_wfr;
	//need to make sure the length of block_values is right
	//need to add another ff to increment current_feature for this section
	feature_response_calc frc(.feature_block_sum(block_values[current_feature2]) , 
												.signs(features[current_feature2].feature_desc) , 
												.weight(weight[current_feature2]) , 
												.result(weighted_feature_result));

	always_ff @(posedge clk, negedge rst) begin
	   if (~rst) begin
	       reg_wfr <= 17'd0;
	   end
	   else if (start_processor || processor_done) begin
	       reg_wfr <= 17'd0;
	   end
	   else begin
	       reg_wfr <= weighted_feature_result;
	   end
	end
	
	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			failed <= 0;
		end
		else if (start_processor || ~started) begin
		      failed <= 0;
		end
		else if (reg_done) begin
		  if (reg_wfr[16] == 1) begin
		      failed <= ((~reg_wfr)+17'd1) < features[current_feature2].threshold;
		                //((~reg_wfr)+17'd1) < (features[current_feature2].threshold-17'h04) ||
		                //((~reg_wfr)+17'd1) > (features[current_feature2].threshold+17'h04);
		                //({1'd0,(~weighted_feature_result) + 8'd1}) < {1'd0,features[current_feature2].threshold-1} ||
		                //({1'd0,(~weighted_feature_result) + 8'd1}) > {1'd0,features[current_feature2].threshold+2};
		  end
		  else begin
		      failed <= reg_wfr < features[current_feature2].threshold;
		                //reg_wfr < (features[current_feature2].threshold-17'h04) ||
		                //reg_wfr > (features[current_feature2].threshold+17'h04);
		                //{1'd0,weighted_feature_result} < {1'd0,features[current_feature2].threshold-1} ||
		                //{1'd0,weighted_feature_result} > {1'd0,features[current_feature2].threshold+2};
		  end
		end
	end

	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			roi_out.roi_row_index <= 0;
			roi_out.roi_col_index <= 0;
			roi_out.roi_side_length <= 0;
		end
		else if (start_processor) begin
			roi_out.roi_row_index <= roi_row_index;
			roi_out.roi_col_index <= roi_col_index;
			roi_out.roi_side_length <= roi_side_length;
		end
	end

	//******************** FINAL CHECK ********************//
	assign passed = !failed;
	assign stage_number_out = stage_number;
	logic reset;
	assign reset = rst;
	logic [8:0] roi_side;
	assign roi_side = roi_side_length;
	logic id;
	assign id = image_done;
	logic [16:0] ft0, ft1, ft2, ft3, ft4, ft5;
	assign ft0 = features[0].threshold;
	assign ft1 = features[1].threshold;
	assign ft2 = features[2].threshold;
	assign ft3 = features[3].threshold;
	assign ft4 = features[4].threshold;
	assign ft5 = features[5].threshold;
	logic live_mode;
	assign live_mode = live;
	logic wfr;
	assign wfr = weighted_feature_result;
	logic [2:0] cf2;
	assign cf2 = current_feature2;
	logic [1:0] fd0, fd1, fd2, fd3, fd4, fd5, fd6, fd7;
	assign fd0 = features[0].feature_desc[0];
	assign fd1 = features[0].feature_desc[1];
	assign fd2 = features[0].feature_desc[2];
	assign fd3 = features[0].feature_desc[3];
	assign fd4 = features[0].feature_desc[4];
	assign fd5 = features[0].feature_desc[5];
	assign fd6 = features[0].feature_desc[6];
	assign fd7 = features[0].feature_desc[7];
	logic [16:0] brow0, brow1, eyel0, eyel1, eyer0, eyer1, nose0, nose1, nose2, nose3, mouth0, mouth1, chin0, chin1;
	assign brow0 = block_values[0][0];
	assign brow1 = block_values[0][1];
	assign nose0 = block_values[1][0];
	assign nose1 = block_values[1][1];
	assign nose2 = block_values[1][2];
	assign nose3 = block_values[1][3];
	assign eyer0 = block_values[2][0];
	assign eyer1 = block_values[2][1];
	assign mouth0 = block_values[3][0];
	assign mouth1 = block_values[3][1];
	assign eyel0 = block_values[4][0];
	assign eyel1 = block_values[4][1];
	assign chin0 = block_values[5][0];
	assign chin1 = block_values[5][1];
		
    /*ila_2 (.clk(clk) , .probe0(clk) , .probe1() , .probe2() , .probe3(integral_pixel_value) , 
            .probe4() ,
           .probe5(roi_row) , .probe6(roi_col) , 
           .probe7(brow0) , .probe8(brow1) , .probe9(nose0) , 
           .probe10(nose1) , .probe11(nose2) , .probe12(nose3) ,
           .probe13(eyel0) , .probe14(eyel1) , .probe15() , .probe16(reg_wfr),
           .probe17(passed) , .probe18() , .probe19(cf2) , .probe20(integral_pixel_value) ,
           .probe21() , .probe22(reset) , .probe23(roi_side) , .probe24() ,
           .probe25() , .probe26() , .probe27() , .probe28() , .probe29() ,
           .probe30() , .probe31() , .probe32() , .probe33() , 
           .probe34() , .probe35() , .probe36() , .probe37() ,
           .probe38() , .probe39() , .probe40(eyer0) , .probe41(eyer1) , .probe42(mouth0) , 
           .probe43(mouth1) , .probe44(chin0) , .probe45(chin1),
           .probe46(integral_values[0][0][0]) , .probe47(integral_values[0][0][1]) , 
           .probe48(integral_values[0][0][2]) , .probe49(integral_values[0][0][3]),
           .probe50(integral_values[0][1][0]) , .probe51(integral_values[0][1][1]) , 
           .probe52(integral_values[0][1][2]) , .probe53(integral_values[0][1][3]));*/
           
    logic pass;
    assign pass = passed;
    logic [19:0] data_out, reg_data_out;
    assign data_out = dout;
    assign reg_data_out = reg_dout;
    logic [2:0] cs, reg_cs1, reg_cs2, reg_cs3;
    assign cs = current_state;
    assign reg_cs1 = reg_state;
    assign reg_cs2 = reg_state2;
    assign reg_cs3 = reg_state3;
    logic rd;
    assign rd = reg_done;
    logic [9:0] rnb;
    assign rnb = reg_num_blocks;
    logic [9:0] count_0;
    assignt count_0 = count[0];
    logic ird;
    assign ird = image_reading_done;
    logic [16:0] brow_threshold0, eyel_threshold4, eyer_threshold2, nose_threshold1, chin_threshold5, mouth_threshold3;
    assign brow_threshold0  = features[0].threshold;
    assign nose_threshold1  = features[1].threshold;
    assign eyer_threshold2  = features[2].threshold;
    assign mouth_threshold3 = features[3].threshold;
    assign eyel_threshold4  = features[4].threshold;
    assign chin_threshold5  = features[5].threshold;
    ila_2 (.clk(clk) , 
           .probe0(roi_row) , .probe1(roi_col) , .probe2(roi_side) , .probe3(pass) ,
           .probe4(eyel0) , .probe5(eyel1) , .probe6(chin0) , .probe7(chin1) , 
           .probe8(nose0) , .probe9(nose1) , .probe10(nose2) , .probe11(nose3) , 
           //nose
           .probe15(integral_values[1][0][0]) , .probe16(integral_values[1][0][1]) , 
           .probe17(integral_values[1][0][2]) , .probe18(integral_values[1][0][3]) , 
           .probe19(integral_values[1][1][0]) , .probe20(integral_values[1][1][1]) , 
           .probe21(integral_values[1][1][2]) , .probe22(integral_values[1][1][3]) , 
           .probe23(integral_values[1][2][0]) , .probe24(integral_values[1][2][1]) , 
           .probe25(integral_values[1][2][2]) , .probe26(integral_values[1][2][3]) , 
           .probe27(integral_values[1][3][0]) , .probe28(integral_values[1][3][1]) , 
           .probe29(integral_values[1][3][2]) , .probe30(integral_values[1][3][3]) , 
           //eyel
           .probe31(integral_values[4][0][0]) , .probe32(integral_values[4][0][1]) ,
           .probe33(integral_values[4][0][2]) , .probe34(integral_values[4][0][3]) , 
           .probe35(integral_values[4][1][0]) , .probe36(integral_values[4][1][1]) , 
           .probe37(integral_values[4][1][2]) , .probe38(integral_values[4][1][3]) , 
           //chin
           .probe39(integral_values[5][0][0]) , .probe40(integral_values[5][0][1]) , 
           .probe41(mouth_threshold3) , .probe42(brow_threshold0) , 
           .probe43(nose_threshold1) , .probe44(eyer_threshold2) , 
           .probe45(eyel_threshold4) , .probe46(chin_threshold5) , 
           //block values
           .probe12(mouth0) , .probe13(mouth1) , .probe14(eyer0) , .probe47(eyer1) ,
           .probe48(brow0) , .probe49(brow1) , .probe50(cf2) , .probe51(reg_wfr) , 
           .probe52(integral_pixel_value) , .probe53(reg_addr2) , .probe54(data_out) ,
           .probe55(cs) , .probe56(reg_cs1) , .probe57(reg_cs2) , .probe58(reg_cs3) , 
           .probe59(rd) , .probe60(rnb) , .probe61(count_0) , .probe62(ird) , .probe63(reg_data_out));

endmodule

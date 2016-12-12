module job_packet_queue 
	(	input  logic clk,
		input  logic rst,
		input  logic send_job,
		input  logic job_ready,
		output logic queue_full,
		output logic queue_empty,
		input  job_packet JOB_IN,
		output job_packet JOB_OUT,
		input  logic [5:0] SW,
		input  logic edit_mode,
		input  logic [16:0] brow_threshold, eyel_threshold, eyer_threshold, 
		input  logic [16:0] chin_threshold, nose_threshold, mouth_threshold);
		
	/*	
    logic [3:0] brow_threshold, eyel_threshold, eyer_threshold, mouth_threshold;
    always_ff @(posedge clk) begin
      if (SW[5:0] == 6'b11_1111) begin
          brow_threshold  <= 4'd0;
          eyel_threshold  <= 4'd0;
          eyer_threshold  <= 4'd0;
          mouth_threshold <= 4'd0; 
      end
      else if (edit_mode == 1) begin
          case (SW[5:4]) 
              (0): brow_threshold  <= SW[3:0];
              (1): eyel_threshold  <= SW[3:0];
              (2): eyer_threshold  <= SW[3:0];
              (3): mouth_threshold <= SW[3:0];
              default: brow_threshold <= 4'd0;
          endcase
      end
    end*/

	ROI empty_roi;
	job_packet empty_job;
	feature empty_feature;
	assign empty_job.roi = empty_roi;
	assign empty_job.stage_number = 1;
	assign empty_job.num_features = 1;
	assign empty_job.weights = '{8{0}};
	assign empty_roi.roi_row_index = 0;
	assign empty_roi.roi_col_index = 0;
	assign empty_roi.roi_side_length = 0;
	assign empty_feature.threshold = 0;
	assign empty_feature.feature_desc = {8{2'd0}};
	assign empty_feature.feature_width = 0;
	assign empty_feature.feature_height = 0;
	assign empty_feature.feature_hor_index = 0;
	assign empty_feature.feature_vert_index = 0;
	assign empty_job.features = '{8{empty_feature}};
	assign empty_feature.hor_block_dimensions = 0;
	assign empty_feature.vert_block_dimensions = 0;
          
     //simple face detection
            feature face_feature_brow;
            assign face_feature_brow.threshold = brow_threshold;//4'd4;
            assign face_feature_brow.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
            assign face_feature_brow.feature_width = 160;
            assign face_feature_brow.feature_height = 40;
            assign face_feature_brow.feature_hor_index = 15;
            assign face_feature_brow.feature_vert_index = 0;
            assign face_feature_brow.hor_block_dimensions = 1;
            assign face_feature_brow.vert_block_dimensions = 2;
            
            feature face_feature_eye_left;
            assign face_feature_eye_left.threshold = eyel_threshold;//4'd4;
            assign face_feature_eye_left.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
            assign face_feature_eye_left.feature_width = 20;
            assign face_feature_eye_left.feature_height = 40;
            assign face_feature_eye_left.feature_hor_index = 40;
            assign face_feature_eye_left.feature_vert_index = 40;
            assign face_feature_eye_left.hor_block_dimensions = 1;
            assign face_feature_eye_left.vert_block_dimensions = 2;
            
            feature face_feature_eye_right;
            assign face_feature_eye_right.threshold = eyer_threshold;//4'd2;
            assign face_feature_eye_right.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
            assign face_feature_eye_right.feature_width = 20;
            assign face_feature_eye_right.feature_height = 40;
            assign face_feature_eye_right.feature_hor_index = 130;
            assign face_feature_eye_right.feature_vert_index = 40;
            assign face_feature_eye_right.hor_block_dimensions = 1;
            assign face_feature_eye_right.vert_block_dimensions = 2;
            
            feature face_feature_nose;
            assign face_feature_nose.threshold = 4'd2;
            assign face_feature_nose.feature_desc = {{4{2'd0}} , 2'd2 , 2'd1 , 2'd1 , 2'd2};
            assign face_feature_nose.feature_width = 40;
            assign face_feature_nose.feature_height = 80;
            assign face_feature_nose.feature_hor_index = 80;
            assign face_feature_nose.feature_vert_index = 40;
            assign face_feature_nose.hor_block_dimensions = 4;
            assign face_feature_nose.vert_block_dimensions = 1;
  
  feature face_feature_mouth;
  assign face_feature_mouth.threshold = mouth_threshold;//4'd3;
  assign face_feature_mouth.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
  assign face_feature_mouth.feature_width = 80;
  assign face_feature_mouth.feature_height = 40;
  assign face_feature_mouth.feature_hor_index = 60;
  assign face_feature_mouth.feature_vert_index = 125;
  assign face_feature_mouth.hor_block_dimensions = 1;
  assign face_feature_mouth.vert_block_dimensions = 2;
  
  feature face_feature_chin;
  assign face_feature_chin.threshold = chin_threshold;
  assign face_feature_chin.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
  assign face_feature_chin.feature_width = 20;
  assign face_feature_chin.feature_height = 40;
  assign face_feature_chin.feature_hor_index = 90;
  assign face_feature_chin.feature_vert_index = 160;
  assign face_feature_chin.hor_block_dimensions = 1;
  assign face_feature_chin.vert_block_dimensions = 2;
    
    //initial job
    ROI initial_roi;
    job_packet initial_job;
    feature initial_feature;
    assign initial_job.roi = initial_roi;
    assign initial_job.stage_number = 1;
    assign initial_job.num_features = 6;
    assign initial_job.weights = '{0 , 0 , 1 , 1 , 1 , 1 , 1 , 1};
    assign initial_roi.roi_row_index = 0;
    assign initial_roi.roi_col_index = 0;
    assign initial_roi.roi_side_length = 50;
    assign initial_job.features = 
        '{empty_feature , empty_feature , face_feature_chin , face_feature_eye_left,
          face_feature_mouth , face_feature_eye_right , face_feature_nose , face_feature_brow};
    //'{empty_feature , empty_feature , empty_feature , empty_feature ,
    //initial_feature4 , initial_feature3 , initial_feature2 , initial_feature};
    //empty_feature,empty_feature,empty_feature,initial_feature0};
          
      /*feature initial_feature0;
          assign initial_feature0.threshold = 23'd3;
          assign initial_feature0.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign initial_feature0.feature_width = 20;
          assign initial_feature0.feature_height = 10;
          assign initial_feature0.feature_hor_index = 10;
          assign initial_feature0.feature_vert_index = 15;
          assign initial_feature0.hor_block_dimensions = 2;
          assign initial_feature0.vert_block_dimensions = 1;
          
      feature initial_feature01;
          assign initial_feature01.threshold = 23'd3;
          assign initial_feature01.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign initial_feature01.feature_width = 10;
          assign initial_feature01.feature_height = 20;
          assign initial_feature01.feature_hor_index = 15;
          assign initial_feature01.feature_vert_index = 10;
          assign initial_feature01.hor_block_dimensions = 1;
          assign initial_feature01.vert_block_dimensions = 2;
     
    //vertical edge
          feature initial_feature;
          assign initial_feature.threshold = 23'd4;
          assign initial_feature.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign initial_feature.feature_width = 20;
          assign initial_feature.feature_height = 10;
          assign initial_feature.feature_hor_index = 0;
          assign initial_feature.feature_vert_index = 115;
          assign initial_feature.hor_block_dimensions = 2;
          assign initial_feature.vert_block_dimensions = 1;
        
          //horizontal edge
          feature initial_feature2;
          assign initial_feature2.threshold = 23'd4;
          assign initial_feature2.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign initial_feature2.feature_width = 10;
          assign initial_feature2.feature_height = 20;
          assign initial_feature2.feature_hor_index = 115;
          assign initial_feature2.feature_vert_index = 0;
          assign initial_feature2.hor_block_dimensions = 1;
          assign initial_feature2.vert_block_dimensions = 2;
          
          feature initial_feature3;
          assign initial_feature3.threshold = 23'd4;
          assign initial_feature3.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign initial_feature3.feature_width = 10;
          assign initial_feature3.feature_height = 20;
          assign initial_feature3.feature_hor_index = 115;
          assign initial_feature3.feature_vert_index = 200;
          assign initial_feature3.hor_block_dimensions = 1;
          assign initial_feature3.vert_block_dimensions = 2;
      
          feature initial_feature4;
          assign initial_feature4.threshold = 23'd4;
          assign initial_feature4.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign initial_feature4.feature_width = 20;
          assign initial_feature4.feature_height = 10;
          assign initial_feature4.feature_hor_index = 200;
          assign initial_feature4.feature_vert_index = 115;
          assign initial_feature4.hor_block_dimensions = 2;
          assign initial_feature4.vert_block_dimensions = 1;*/

	logic [3:0] queue_size;
	assign queue_size = 15;
	logic [3:0] queue_base_index, queue_end_index;
	//queue size depends on the number of processors, make the queue larger than
	//the number of processors so that the queue will never be full
	job_packet queued_jobs [15:0];
	always_ff @(posedge clk, negedge rst) begin
		JOB_OUT <= queued_jobs[queue_base_index];
		if (~rst) begin
			queue_end_index <= 1;
			queue_base_index <= 0;
			queued_jobs <= 
				  '{initial_job , initial_job , initial_job , initial_job , 
					initial_job , initial_job , initial_job , initial_job , 
					initial_job , initial_job , initial_job , initial_job ,
					initial_job , initial_job , initial_job , initial_job};
		end
		else if (send_job & !queue_empty) begin
			if (queue_base_index != queue_end_index) begin
				//JOB_OUT <= queued_jobs[queue_base_index];
				queue_base_index <= queue_base_index + 1;
			end
		end
		else if (job_ready && !queue_full) begin
			if (queue_base_index-1 != queue_end_index) begin
				queued_jobs[queue_end_index] <= JOB_IN;
				queue_end_index <= queue_end_index + 1;
			end
		end
	end

	assign queue_empty = (queue_base_index == queue_end_index);
	assign queue_full = ((queue_end_index-queue_base_index) == queue_size);

	/*always_comb begin
		queue_full = 0;
		queue_empty = 0;
		if (queue_base_index == queue_end_index) begin
			queue_empty = 1;
		end
		if (queue_base_index == (queue_end_index+1)) begin
			queue_full = 1;
		end
	end*/

endmodule

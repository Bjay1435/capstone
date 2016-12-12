module job_packet_builder
	(	input  logic clk, rst, 
	    input  ROI prev_roi,
		input  logic prev_stage_passed,
		input  logic [3:0] prev_stage_number,
		output job_packet jp_out,
		input  logic [5:0] SW,
		input  logic edit_mode,
        input  logic [16:0] brow_threshold, eyel_threshold, eyer_threshold, 
        input  logic [16:0] mouth_threshold, nose_threshold, chin_threshold);

	feature empty_feature;
  assign empty_feature.threshold = 0;
  assign empty_feature.feature_desc = 0;
  assign empty_feature.feature_width = 0;
  assign empty_feature.feature_height = 0;
  assign empty_feature.feature_hor_index = 0;
  assign empty_feature.feature_vert_index = 0;
  assign empty_feature.hor_block_dimensions = 0;
  assign empty_feature.vert_block_dimensions = 0;
  
  ROI next_roi;
  
  /*logic [3:0] brow_threshold, eyel_threshold, eyer_threshold, mouth_threshold;
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
  
  logic [3:0] num_stages;
  //temporary value, needs to be determined and reassigned
  assign num_stages = 1; 

  //next ROI module
  next_roi nroi
      (    .roi_passed(prev_stage_passed),
          .roi_hor_index(prev_roi.roi_col_index),
          .roi_vert_index(prev_roi.roi_row_index),
          .roi_side_length(prev_roi.roi_side_length),
          .was_final_stage(prev_stage_number == num_stages),
          .next_roi_hor_index(next_roi.roi_col_index),
          .next_roi_vert_index(next_roi.roi_row_index),
          .next_roi_side_length(next_roi.roi_side_length));
  
     //simple face detection
          feature face_feature_brow;
          logic [8:0] temp;
          assign temp = prev_roi.roi_side_length;
          assign face_feature_brow.threshold = brow_threshold;//4'd4;
          assign face_feature_brow.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign face_feature_brow.feature_width = prev_roi.roi_side_length - temp/5;//160;
          assign face_feature_brow.feature_height = temp/5;//40;
          assign face_feature_brow.feature_hor_index = (temp/10) - (temp/40);//15;
          assign face_feature_brow.feature_vert_index = 0;
          assign face_feature_brow.hor_block_dimensions = 1;
          assign face_feature_brow.vert_block_dimensions = 2;
          
          feature face_feature_eye_left;
          assign face_feature_eye_left.threshold = eyel_threshold;//4'd4;
          assign face_feature_eye_left.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign face_feature_eye_left.feature_width = temp/10;//20;
          assign face_feature_eye_left.feature_height = temp/5;//40;
          assign face_feature_eye_left.feature_hor_index = temp/5 + temp/40;//41;
          assign face_feature_eye_left.feature_vert_index = temp/5;//40;
          assign face_feature_eye_left.hor_block_dimensions = 1;
          assign face_feature_eye_left.vert_block_dimensions = 2;
          
          feature face_feature_eye_right;
          assign face_feature_eye_right.threshold = eyer_threshold;//4'd2;
          assign face_feature_eye_right.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign face_feature_eye_right.feature_width = temp/10;//20;
          assign face_feature_eye_right.feature_height = temp/5;//40;
          assign face_feature_eye_right.feature_hor_index = temp/2 + 3*(temp/20) + temp/40;//131;
          assign face_feature_eye_right.feature_vert_index = temp/5;//40;
          assign face_feature_eye_right.hor_block_dimensions = 1;
          assign face_feature_eye_right.vert_block_dimensions = 2;
          
          feature face_feature_mouth;
          assign face_feature_mouth.threshold = mouth_threshold;//4'd3;
          assign face_feature_mouth.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
          assign face_feature_mouth.feature_width = (temp/5)*2;//80;
          assign face_feature_mouth.feature_height = temp/5;//40;
          assign face_feature_mouth.feature_hor_index = (temp/10)*3;//60;
          assign face_feature_mouth.feature_vert_index = temp/2 + 2*(temp/20) + temp/40;//125;
          assign face_feature_mouth.hor_block_dimensions = 1;
          assign face_feature_mouth.vert_block_dimensions = 2;
          
          feature face_feature_nose;
          assign face_feature_nose.threshold = nose_threshold;//4'd2;
          assign face_feature_nose.feature_desc = {{4{2'd0}} , 2'd2 , 2'd1 , 2'd1 , 2'd2};
          assign face_feature_nose.feature_width = temp/5;//40;
          assign face_feature_nose.feature_height = 2*(temp/5);//80;
          assign face_feature_nose.feature_hor_index = 2*(temp/5);//80;
          assign face_feature_nose.feature_vert_index = temp/5;//40;
          assign face_feature_nose.hor_block_dimensions = 4;
          assign face_feature_nose.vert_block_dimensions = 1;
  
  feature face_feature_chin;
  assign face_feature_chin.threshold = chin_threshold;//4'd0;
  assign face_feature_chin.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
  assign face_feature_chin.feature_width = temp/10;//20;
  assign face_feature_chin.feature_height = temp/5;//40;
  assign face_feature_chin.feature_hor_index = temp/2 - temp/20;//90;
  assign face_feature_chin.feature_vert_index = temp/2 + temp/4 + temp/20;//160;
  assign face_feature_chin.hor_block_dimensions = 1;
  assign face_feature_chin.vert_block_dimensions = 2;

      //corner detection
      feature initial_feature0;
      assign initial_feature0.threshold = 4'd4;
      assign initial_feature0.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
      assign initial_feature0.feature_width = 20;
      assign initial_feature0.feature_height = 10;
      assign initial_feature0.feature_hor_index = 10;
      assign initial_feature0.feature_vert_index = 15;
      assign initial_feature0.hor_block_dimensions = 2;
      assign initial_feature0.vert_block_dimensions = 1;
      feature initial_feature01;
      assign initial_feature01.threshold = 4'd3;
      assign initial_feature01.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
      assign initial_feature01.feature_width = 10;
      assign initial_feature01.feature_height = 20;
      assign initial_feature01.feature_hor_index = 15;
      assign initial_feature01.feature_vert_index = 10;
      assign initial_feature01.hor_block_dimensions = 1;
      assign initial_feature01.vert_block_dimensions = 2;

      //box detection
      //left vertical edge
      feature initial_feature;
      assign initial_feature.threshold = 4'd4;
      assign initial_feature.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
      assign initial_feature.feature_width = 20;
      assign initial_feature.feature_height = 10;
      assign initial_feature.feature_hor_index = (jp_out.roi.roi_side_length/2)-110;//0;
      assign initial_feature.feature_vert_index = (jp_out.roi.roi_side_length/2)-5;//115;
      assign initial_feature.hor_block_dimensions = 2;
      assign initial_feature.vert_block_dimensions = 1;
      //top horizontal edge
      feature initial_feature2;
      assign initial_feature2.threshold = 4'd4;
      assign initial_feature2.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
      assign initial_feature2.feature_width = 10;
      assign initial_feature2.feature_height = 20;
      assign initial_feature2.feature_hor_index = (jp_out.roi.roi_side_length/2)-5;//115;
      assign initial_feature2.feature_vert_index = (jp_out.roi.roi_side_length/2)-110;//0;
      assign initial_feature2.hor_block_dimensions = 1;
      assign initial_feature2.vert_block_dimensions = 2;
      //bottom horizontal edge
      feature initial_feature3;
      assign initial_feature3.threshold = 4'd4;
      assign initial_feature3.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
      assign initial_feature3.feature_width = 10;
      assign initial_feature3.feature_height = 20;
      assign initial_feature3.feature_hor_index = (jp_out.roi.roi_side_length/2)-5;//115;
      assign initial_feature3.feature_vert_index = (jp_out.roi.roi_side_length/2)-110+200;//200;
      assign initial_feature3.hor_block_dimensions = 1;
      assign initial_feature3.vert_block_dimensions = 2;      
      //right vertical edge
      feature initial_feature4;
      assign initial_feature4.threshold = 4'd4;
      assign initial_feature4.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
      assign initial_feature4.feature_width = 20;
      assign initial_feature4.feature_height = 10;
      assign initial_feature4.feature_hor_index = (jp_out.roi.roi_side_length/2)-110+200;//200;
      assign initial_feature4.feature_vert_index = (jp_out.roi.roi_side_length/2)-5;//115;
      assign initial_feature4.hor_block_dimensions = 2;
      assign initial_feature4.vert_block_dimensions = 1;

	logic [3:0] next_stage_number;
	assign next_stage_number = (prev_stage_number<num_stages)?
							   (prev_stage_number+1):(4'd1);
	assign jp_out.roi = next_roi;
	assign jp_out.stage_number = next_stage_number;
	assign jp_out.weights = '{0,0,1,1,1,1,1,1};
	
	assign jp_out.num_features = 6;
    assign jp_out.features = 
        '{empty_feature , empty_feature , face_feature_chin , face_feature_eye_left,
          face_feature_mouth , face_feature_eye_right , face_feature_nose , face_feature_brow};
          
endmodule

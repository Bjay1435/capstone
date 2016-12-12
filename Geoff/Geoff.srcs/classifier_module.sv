

typedef struct {
	ROI roi;
	feature features [7:0];
	logic [3:0] stage_number;
	logic [2:0] num_features;
	logic [9:0] weights [7:0];
} job_packet;

module classifier_module 
	(	input  logic clk,
		input  logic rst,
		input  logic start_image,
		input  logic [3:0] mem_value,
		input  logic mem_value_valid,
		//output logic [9:0] col_index1,
		//output logic [8:0] row_index1,
		output logic mem_addr_valid,
		output logic image_done,
		output logic processor_passed, processor_finished,proc_start,
		output ROI passed_roi,
		input  logic [7:0] CI_ROI_INDEX,
		input  logic [3:0] image_region,
		input  logic [6:0] SW,
		input  logic edit_mode, live_mode,
		input  logic [2:0] feature_index);

  logic [16:0] brow_threshold, eyel_threshold, eyer_threshold, mouth_threshold, nose_threshold, chin_threshold;
  always_ff @(posedge clk) begin
    if (edit_mode == 1) begin
        case (feature_index) 
            (0): brow_threshold  <= 17'h00E50;//{10'd0,SW[6:0]};
            (1): nose_threshold  <= 17'h004A7;//{10'd0,SW[6:0]};
            (2): eyer_threshold  <= 17'h00220;//{10'd0,SW[6:0]};
            (3): mouth_threshold <= 17'h00BF8;//{10'd0,SW[6:0]};
            (4): eyel_threshold  <= 17'h00004;//{10'd0,SW[6:0]};
            (5): chin_threshold  <= 17'h0034C;//{10'd0,SW[6:0]};
            default: brow_threshold <= 17'd0;
        endcase
    end/*
    brow_threshold <= 8'h56;
    eyel_threshold <= 8'h0F;
    eyer_threshold <= 8'h4B;
    nose_threshold <= 8'h2C;
    chin_threshold <= 8'h5A;
    mouth_threshold <= 8'h4B;*/
  end

	//empty job
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
            assign face_feature_eye_left.feature_hor_index = 40;//1
            assign face_feature_eye_left.feature_vert_index = 40;
            assign face_feature_eye_left.hor_block_dimensions = 1;
            assign face_feature_eye_left.vert_block_dimensions = 2;
            
            feature face_feature_eye_right;
            assign face_feature_eye_right.threshold = eyer_threshold;//4'd2;
            assign face_feature_eye_right.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
            assign face_feature_eye_right.feature_width = 20;
            assign face_feature_eye_right.feature_height = 40;
            assign face_feature_eye_right.feature_hor_index = 130;//1
            assign face_feature_eye_right.feature_vert_index = 40;
            assign face_feature_eye_right.hor_block_dimensions = 1;
            assign face_feature_eye_right.vert_block_dimensions = 2;
            
            feature face_feature_nose;
            assign face_feature_nose.threshold = nose_threshold;//4'd2;
            assign face_feature_nose.feature_desc = {{4{2'd0}} , 2'd2 , 2'd1 , 2'd1 , 2'd2};
            assign face_feature_nose.feature_width = 40;
            assign face_feature_nose.feature_height = 80;
            assign face_feature_nose.feature_hor_index = 80;//78
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
            assign face_feature_chin.threshold = chin_threshold;//4'd0;
            assign face_feature_chin.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
            assign face_feature_chin.feature_width = 20;
            assign face_feature_chin.feature_height = 40;
            assign face_feature_chin.feature_hor_index = 90;
            assign face_feature_chin.feature_vert_index = 160;
            assign face_feature_chin.hor_block_dimensions = 1;
            assign face_feature_chin.vert_block_dimensions = 2;
              
      /*feature initial_feature0;
              assign initial_feature0.threshold = 4'd3;
              assign initial_feature0.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
              assign initial_feature0.feature_width = 20;
              assign initial_feature0.feature_height = 10;
              assign initial_feature0.feature_hor_index = 10;
              assign initial_feature0.feature_vert_index = 15;
              assign initial_feature0.hor_block_dimensions = 2;
              assign initial_feature0.vert_block_dimensions = 1;
              
    //vertical edge
                    feature initial_feature;
                    assign initial_feature.threshold = 4'd4;
                    assign initial_feature.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
                    assign initial_feature.feature_width = 20;
                    assign initial_feature.feature_height = 10;
                    assign initial_feature.feature_hor_index = 0;
                    assign initial_feature.feature_vert_index = 115;
                    assign initial_feature.hor_block_dimensions = 2;
                    assign initial_feature.vert_block_dimensions = 1;
                  
                    //horizontal edge
                    feature initial_feature2;
                    assign initial_feature2.threshold = 4'd4;
                    assign initial_feature2.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
                    assign initial_feature2.feature_width = 10;
                    assign initial_feature2.feature_height = 20;
                    assign initial_feature2.feature_hor_index = 115;
                    assign initial_feature2.feature_vert_index = 0;
                    assign initial_feature2.hor_block_dimensions = 1;
                    assign initial_feature2.vert_block_dimensions = 2;
                    
                    feature initial_feature3;
                    assign initial_feature3.threshold = 4'd4;
                    assign initial_feature3.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
                    assign initial_feature3.feature_width = 10;
                    assign initial_feature3.feature_height = 20;
                    assign initial_feature3.feature_hor_index = 115;
                    assign initial_feature3.feature_vert_index = 200;
                    assign initial_feature3.hor_block_dimensions = 1;
                    assign initial_feature3.vert_block_dimensions = 2;
                
                    feature initial_feature4;
                    assign initial_feature4.threshold = 4'd4;
                    assign initial_feature4.feature_desc = {{6{2'd0}} , 2'd1 , 2'd2};
                    assign initial_feature4.feature_width = 20;
                    assign initial_feature4.feature_height = 10;
                    assign initial_feature4.feature_hor_index = 200;
                    assign initial_feature4.feature_vert_index = 115;
                    assign initial_feature4.hor_block_dimensions = 2;
                    assign initial_feature4.vert_block_dimensions = 1;*/

    logic sys_rst;
	//Job Packet Queue
	job_packet jpq_job_in, jpq_job_out;
	logic jpq_rst, jpq_full, jpq_empty, jpq_job_ready, jpq_send_job;
	job_packet_queue JPQ
		(	.clk(clk),
			.rst(rst),
			.JOB_IN(jpq_job_in),
			.JOB_OUT(jpq_job_out),
			.queue_full(jpq_full),
			.queue_empty(jpq_empty),
			.send_job(jpq_send_job), //POP
			.job_ready(jpq_job_ready), //PUSH
			.edit_mode(edit_mode),
			.brow_threshold(brow_threshold),
			.eyel_threshold(eyel_threshold),
			.eyer_threshold(eyer_threshold),
			.nose_threshold(nose_threshold),
			.chin_threshold(chin_threshold),
			.mouth_threshold(mouth_threshold));

	//Feature Processor 1
	logic fp1_rst, fp1_start, fp1_passed, fp1_done;
	logic mem_indices_valid;
	logic [3:0] fp1_stage_out, ipv, rpv;
	ROI fp1_roi_out;
	feature features_out [7:0];
	job_packet jp1;
	logic [2:0] cf2, cf1;
	logic [1:0] fp1_cs;
	logic feat_read_start, started;
	logic [9:0] wfr, rc;
	logic [1:0][3:0] bv;
	logic [3:0][3:0] iv, iv22;
	logic [19:0] addr;
	logic [255:0] dout;
	logic id;
	assign id = image_done;
	logic live;
    assign live = live_mode;
	feature_processor FP1
		(	.clk(clk),
			.rst(rst),
			.start_processor(fp1_start),
			.stage_number(jp1.stage_number),
			.num_features(jp1.num_features),
			.features(jp1.features),
			.roi_row_index(jp1.roi.roi_row_index),
			.roi_col_index(jp1.roi.roi_col_index),
			.roi_side_length(jp1.roi.roi_side_length),
			.weight(jp1.weights),
			//.integral_pixel_value(mem_value),//(mem_value_valid)?(mem_value):(4'd0)),
			.pixel_value_valid(mem_value_valid),
			//.row_index(row_index1),
			//.col_index(col_index1),
			.passed(fp1_passed),
			.processor_done(fp1_done),
			.stage_number_out(fp1_stage_out),
			.roi_out(fp1_roi_out),
			.mem_indices_valid(mem_indices_valid),
			.image_done(id),
			.live(live)
			//.current_feature2(cf2),
			//.fp_cs(fp1_cs),
			//.frs(feat_read_start),
			//.strtd(started)
			//.wfr(wfr),
			//.bv(bv),
			//.iv(iv),
			//.iv2(iv22),
			//.rc(rc),
			//.cf1(cf1),
			//.ipv(ipv),
			//.rpv(rpv),
			//.addrb(addr),
			//.doutb(dout));
			);
	assign processor_passed = fp1_passed;
	assign passed_roi = fp1_roi_out;
    assign proc_start = fp1_start;

	//job packet builder module
	job_packet next_jp;
	job_packet_builder jpb
		(	.clk(clk),
		    .rst(rst),
		    .prev_roi(fp1_roi_out),
			.prev_stage_passed(fp1_passed),
			.prev_stage_number(fp1_stage_out),
			.jp_out(next_jp),
			.edit_mode(edit_mode),
			.brow_threshold(brow_threshold),
			.eyel_threshold(eyel_threshold),
			.eyer_threshold(eyer_threshold),
			.nose_threshold(nose_threshold),
			.chin_threshold(chin_threshold),
			.mouth_threshold(mouth_threshold));

	logic [8:0] max_roi_size;
	assign max_roi_size = 71;
	//assign image_done = next_jp.roi.roi_side_length >= max_roi_size;

	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			image_done <= 0;
		end
		else if (jp1.roi.roi_side_length >= max_roi_size) begin
			image_done <= 1;
		end
	end


	logic queue_wait, fp_inter;
	//jp builder is combinational so the jpq ready can be the processor done
	always_ff @(posedge clk, negedge rst) begin
		if (~rst) begin
			jpq_job_in <= initial_job;
			jpq_send_job <= 0;
			fp1_start <= 0;
			queue_wait <= 0;
			fp_inter <= 0;
			jp1 <= initial_job;
		end
	    else if (start_image) begin
            jpq_send_job = 1;
        end
        else if (fp_inter) begin
            fp1_start <= 1;
            fp_inter <= 0;
        end
        else if (jpq_send_job) begin
            fp_inter <= 1;
            jpq_send_job <= 0;
            jp1 <= jpq_job_out;
        end
        else if (queue_wait) begin
            jpq_send_job <= 1;
            queue_wait <= 0;
        end
        else if (jpq_job_ready) begin
            jpq_job_ready <= 0;
            queue_wait <= 1;
        end
		else if (fp1_done) begin
			jpq_job_in <= next_jp;
			jpq_job_ready <= 1;
			fp1_start <= 0;
		end
		else begin
			jpq_job_in <= next_jp;
			jpq_job_ready <= fp1_done;
			fp1_start <= 0;
		end
	end

	//figure out where the image is going to be in memoryrow_index>passed_rois[SW[7:0]].roi_row_index && 
    //                row_index<passed_rois[SW[7:0]].roi_row_index+passed_rois[SW[6:0]].roi_side_length &&
    //                col_index>passed_rois[SW[7:0]].roi_col_index &&
    //                col_index<passed_rois[SW[7:0]].roi_col_index+passed_rois[SW[6:0]].roi_side_length
	assign mem_addr_valid = mem_indices_valid;
	assign processor_finished = fp1_done;
	
	logic [2:0] cur_feat_1;
	logic [8:0] ri1;
	logic [9:0] ci1, wfr1;
	logic [3:0] bv1,bv2;
	logic [9:0] iv1, iv2, iv3, iv4;
	logic [9:0] iv5, iv6, iv7, iv8;
	logic [9:0] read_count;
	assign read_count = 0;//rc;
	assign ri1 = 0;//row_index1;
	assign ci1 = 0;//col_index1;
	assign wfr1 = 0;//wfr;
	assign bv1 = 0;//bv[0];
	assign bv2 = 0;//bv[1];
	assign iv1 = 0;//iv[0];
	assign iv2 = 0;//iv[1];
	assign iv3 = 0;//iv[2];
	assign iv4 = 0;//iv[3];
	assign iv5 = 0;//iv22[0];
	assign iv6 = 0;//iv22[1];
	assign iv7 = 0;//iv22[2];
	assign iv8 = 0;//iv22[3];
	logic [3:0] mvalue;
	assign mvalue = 0;//mem_value;
	assign cur_feat_1 = 0;//cf1;
	logic [3:0] ir;
	assign ir = image_region;
	logic [7:0] int_pix_val;
	assign int_pix_val = 0;//ipv;
	logic [7:0] reg_pix_val;
	assign reg_pix_val = 0;//rpv;
	logic si;
	assign si = start_image;
	logic [19:0] addrb;
	logic [255:0] doutb;
	assign addrb = 0;//addr;
	assign doutb = 0;//dout;
	assign cf2 = 0;
	
	logic [7:0] roi_index_temp;
	assign roi_index_temp = CI_ROI_INDEX;
	/*ila_0 (.clk(clk) , .probe0(rst) , .probe1(feat_read_start) , .probe2(next_jp.roi.roi_side_length) , 
    .probe3(image_done) , .probe4(fp1_start) , .probe5(jp1.roi.roi_col_index) , .probe6(jp1.roi.roi_side_length) , 
    .probe7(fp1_done) , .probe8(jp1.num_features) , .probe9(jp1.roi.roi_row_index) , .probe10(cf2) , .probe11(si) ,
    .probe12(fp1_passed), .probe13(fp1_cs) , .probe14(roi_index_temp) , .probe15(ri1) , .probe16(ci1) , .probe17(wfr1) ,
    .probe18({6'd0,bv1}) , .probe19({6'd0,bv2}) , .probe20(iv1) , .probe21(iv2) , .probe22(iv3) , .probe23(iv4) , .probe30(cur_feat_1),
    .probe24(iv5) , .probe25(iv6) , .probe26(iv7) , .probe27(iv8) , .probe28(mvalue) , .probe29(read_count) ,
    .probe31(ir) , .probe32({6'd0,jp1.features[0].threshold}) , .probe33(int_pix_val) , .probe34(reg_pix_val), .probe35(jp1.stage_number),
    .probe36(addrb) , .probe37(doutb));
*/
endmodule

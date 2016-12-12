`timescale 1ns / 1ps

(* mark_debug *) logic [9:0] row_index;

typedef struct {
	logic [16:0] threshold;
	logic [7:0][1:0] feature_desc;
	logic [9:0] feature_width;
	logic [8:0] feature_height;
	logic [9:0] feature_hor_index;
	logic [8:0] feature_vert_index;
	logic [2:0] hor_block_dimensions;
	logic [2:0] vert_block_dimensions;
} feature;

typedef struct {
	logic [8:0] roi_row_index;
	logic [9:0] roi_col_index;
	logic [8:0] roi_side_length;
} ROI;

module CHIP_INTERFACE(
    input  logic GCLK,
    input  logic BTNC,BTNL,BTNR,BTNU,BTND,
    input  logic [7:0] SW,
    output logic [3:0] VGA_R, VGA_G, VGA_B,
    output logic [7:0] LED,
    output logic VGA_VS, VGA_HS);
    
    logic clk, clk2;
    logic [10:0] temp_clk;
    assign clk = temp_clk[1];
    assign clk2 = temp_clk[7];
    always_ff @(posedge GCLK) begin
        temp_clk <= temp_clk + 1;
    end
    
    logic disp_done;
    logic disp_start;
    logic [9:0]  row_index , col_index;
    assign disp_done = (row_index == 480) && (col_index == 639);
    assign disp_start = (row_index == 480) && (col_index == 640);
    logic [11:0] pixel_in , pixel;
    
    VGA_INTERFACE vga (.*);
    
    logic [2:0] feature_index;
    logic r_pressed, l_pressed;
    always_ff @(posedge clk, posedge BTNR, posedge BTNC) begin
        if (BTNC) begin
            feature_index <= 3'd0;
        end
        else if (BTNR) begin
            feature_index <= SW[2:0];
        end
    end
    
    logic live_mode, threshold_edit_mode, u_pressed;
    always_ff @(posedge GCLK, posedge BTNC , posedge BTNU) begin
        if (BTNC) begin
            live_mode <= 0;
            u_pressed <= 0;
        end
        else if (BTNU && !u_pressed) begin
            live_mode <= ~live_mode;
            u_pressed <= 1;
        end
        else if (~BTNU && u_pressed) begin
            u_pressed <= 0;
        end
    end
    assign threshold_edit_mode = SW[7];
    
    logic [3:0] cm_mem_value;
    logic [9:0] cm_col_index;
    logic [8:0] cm_row_index;
    logic ena , wea , rsta;
    logic [7:0] douta, dina, doutb;
    logic [16:0] addra, addrb, reg_addr;
    assign addra = ({7'd0,col_index}/2)+(({7'd0,row_index}/2) * 17'd320);
    
    always_ff @(posedge clk) begin
        reg_addr <= addra;
    end
    
    blk_mem_gen_1(.clka(clk) , .addra(reg_addr) , .dina({64{4'hF}}) , .douta(douta) , .wea(0));
                  
    assign pixel_in[3:0] =  (douta>>(4))&4'hF;
    assign pixel_in[7:4] =  (douta>>(4))&4'hF;
    assign pixel_in[11:8] = (douta>>(4))&4'hF;
                  
    logic [30:0] counter;
    always_ff @(posedge GCLK) begin
        counter <= counter+1;
    end
    
    ROI empty_roi;
    assign empty_roi.roi_row_index = 0;
    assign empty_roi.roi_col_index = 0;
    assign empty_roi.roi_side_length = 0;
    
    ROI passed_rois [255:0];
    feature passed_features [255:0][7:0];
    logic [7:0] roi_index;
    logic cm_mem_value_valid, cm_addr_valid, cm_done, cm_proc_pass, cm_proc_finished;
    logic cm_proc_start;
    ROI roi_out;
  
    logic cm_start;
    logic BTND_pressed;
    always_ff @(posedge clk) begin
        if (BTND && ~BTND_pressed) begin
            BTND_pressed <= 1;
            cm_start <= 1;
        end
        else if (BTND_pressed && BTND) begin
            cm_start <= 0;
        end
        else if (~BTND) begin
            BTND_pressed <= 0;
            cm_start <= 0;
        end
    end

    assign cm_mem_value_valid = cm_addr_valid;
        
    logic roi_rst;
    assign roi_rst = BTNC || (disp_done&&live_mode);

    feature features_out [7:0];
    classifier_module cm (
        .clk(GCLK), 
        .rst(~(roi_rst)), 
        .start_image(cm_start||(disp_start&&live_mode)), 
        .mem_value(cm_mem_value), 
        .mem_value_valid(cm_mem_value_valid),
        .mem_addr_valid(cm_addr_valid), 
        .image_done(cm_done), 
        .processor_finished(cm_proc_finished), 
        .processor_passed(cm_proc_pass), 
        .passed_roi(roi_out), 
        .proc_start(cm_proc_start), 
        .CI_ROI_INDEX(roi_index), 
        .image_region(image_region) , 
        .SW(SW[6:0]) ,
        .edit_mode(threshold_edit_mode), 
        .live_mode(live_mode) , 
        .feature_index(feature_index));
        

    logic roi_write;
    always_ff @(posedge GCLK, posedge roi_rst) begin
        if (roi_rst) begin
            roi_index <= 0;
            passed_rois <= '{256{empty_roi}};
            roi_write <= 0;
        end
        else if (roi_write && !cm_proc_finished) begin
            roi_write <= 0;
        end
        else if (cm_proc_finished && cm_proc_pass && 
                 roi_index < 255 && roi_out.roi_side_length > 0 && 
                 ~cm_done && ~roi_write && 
                 ~(roi_out.roi_row_index == 0 && roi_out.roi_col_index == 0)) begin
            passed_rois[roi_index] <= roi_out;
            roi_index <= (roi_index+1);
            roi_write <= 1;
        end
    end
    
    assign LED[6] = cm_start||(disp_start&&live_mode);
    assign LED[5:3] = feature_index;
    assign LED[2] = live_mode;
    assign LED[1] = threshold_edit_mode;
    assign LED[0] = cm_done;
                  
    pixel_eval pe (.row_index(row_index/2) , .col_index(col_index/2) , .*);
    
endmodule

module pixel_eval 
    ( input  ROI passed_rois[255:0],
      input  logic [11:0] pixel_in,
      input  logic [7:0] roi_index, SW,
      input  logic [8:0] row_index,
      input  logic [9:0] col_index, shift_count,
      output logic [11:0] pixel);

   logic [8:0] temp;
   always_comb begin
        /*if (SW[6]) begin
        pixel = (row_index>passed_rois[SW[5:0]*4 + 3].roi_row_index &&
                row_index<passed_rois[SW[5:0]*4 + 3].roi_row_index+passed_rois[SW[5:0]*4 + 3].roi_side_length &&
                col_index>passed_rois[SW[5:0]*4 + 3].roi_col_index &&
                col_index<passed_rois[SW[5:0]*4 + 3].roi_col_index+passed_rois[SW[5:0]*4 + 3].roi_side_length &&
                passed_rois[SW[5:0]*4 + 3].roi_side_length > 0)?
                
                (pixel_in&12'b1111_0000_0000):
                (row_index>passed_rois[SW[5:0]*4 + 2].roi_row_index && 
                row_index<passed_rois[SW[5:0]*4 + 2].roi_row_index+passed_rois[SW[5:0]*4 + 2].roi_side_length &&
                col_index>passed_rois[SW[5:0]*4 + 2].roi_col_index &&
                col_index<passed_rois[SW[5:0]*4 + 2].roi_col_index+passed_rois[SW[5:0]*4 + 2].roi_side_length &&
                passed_rois[SW[5:0]*4 + 2].roi_side_length > 0)?
                
                (pixel_in&12'b1111_0000_0000):
                (row_index>passed_rois[SW[5:0]*4 + 1].roi_row_index && 
                row_index<passed_rois[SW[5:0]*4 + 1].roi_row_index+passed_rois[SW[5:0]*4 + 1].roi_side_length &&
                col_index>passed_rois[SW[5:0]*4 + 1].roi_col_index &&
                col_index<passed_rois[SW[5:0]*4 + 1].roi_col_index+passed_rois[SW[5:0]*4 + 1].roi_side_length &&
                passed_rois[SW[5:0]*4 + 1].roi_side_length > 0)?
                
                (pixel_in&12'b1111_0000_0000):
                (row_index>passed_rois[SW[5:0]*4].roi_row_index && 
                row_index<passed_rois[SW[5:0]*4].roi_row_index+passed_rois[SW[5:0]*4].roi_side_length &&
                col_index>passed_rois[SW[5:0]*4].roi_col_index &&
                col_index<passed_rois[SW[5:0]*4].roi_col_index+passed_rois[SW[5:0]*4].roi_side_length &&
                passed_rois[SW[5:0]*4].roi_side_length > 0)?
                */
                /*((col_index>220+shift_count && col_index<420+shift_count))?(12'h0fbb):(12'h0400):
                ((col_index>220+shift_count && col_index<420+shift_count))?(12'h0fff):(12'h000);*/
                
                //centered square display logic
      /*          (pixel_in&12'b1111_0000_0000):
                pixel_in;
        end
        else begin*/
        
        temp = passed_rois[SW[6:0]].roi_side_length;
        pixel = (row_index>passed_rois[SW[6:0]].roi_row_index && 
                row_index<passed_rois[SW[6:0]].roi_row_index+passed_rois[SW[6:0]].roi_side_length &&
                col_index>passed_rois[SW[6:0]].roi_col_index &&
                col_index<passed_rois[SW[6:0]].roi_col_index+passed_rois[SW[6:0]].roi_side_length &&
                passed_rois[SW[6:0]].roi_side_length > 0)?
                //brow
                (row_index>passed_rois[SW[6:0]].roi_row_index && 
                row_index<passed_rois[SW[6:0]].roi_row_index+temp/5 &&
                col_index>passed_rois[SW[6:0]].roi_col_index+(temp/10)-(temp/40) &&
                col_index<passed_rois[SW[6:0]].roi_col_index+(temp/10)-(temp/40)+temp-(temp/5))?(pixel_in&12'b0000_1111_0000):
                //left eye
                (row_index>(passed_rois[SW[6:0]].roi_row_index+(temp/5)) && 
                row_index<passed_rois[SW[6:0]].roi_row_index+2*(temp/5) &&
                col_index>passed_rois[SW[6:0]].roi_col_index+(temp/5)+(temp/40) &&
                col_index<passed_rois[SW[6:0]].roi_col_index+(temp/5)+(temp/40)+(temp/10))?(pixel_in&12'b0000_1111_0000):
                //right eye
                (row_index>passed_rois[SW[6:0]].roi_row_index+temp/5 && 
                row_index<passed_rois[SW[6:0]].roi_row_index+2*(temp/5) &&
                col_index>passed_rois[SW[6:0]].roi_col_index+(temp/2)+3*(temp/20)+(temp/40) &&
                col_index<passed_rois[SW[6:0]].roi_col_index+(temp/2)+3*(temp/20)+(temp/40)+(temp/10))?(pixel_in&12'b0000_1111_0000):
                //nose
                (row_index>passed_rois[SW[6:0]].roi_row_index+temp/5 && 
                row_index<passed_rois[SW[6:0]].roi_row_index+3*(temp/5) &&
                col_index>passed_rois[SW[6:0]].roi_col_index+2*(temp/5) &&//78 &&
                col_index<passed_rois[SW[6:0]].roi_col_index+3*(temp/5))?(pixel_in&12'b0000_1111_0000):
                //mouth
                (row_index>passed_rois[SW[6:0]].roi_row_index+(temp/2)+2*(temp/20)+(temp/40) && 
                row_index<passed_rois[SW[6:0]].roi_row_index+(temp/2)+2*(temp/20)+(temp/40)+(temp/5) &&
                col_index>passed_rois[SW[6:0]].roi_col_index+3*(temp/10) &&
                col_index<passed_rois[SW[6:0]].roi_col_index+3*(temp/10)+2*(temp/5))?(pixel_in&12'b0000_1111_0000):
                //chin
                (row_index>passed_rois[SW[6:0]].roi_row_index+(temp/2)+(temp/4)+(temp/20) && 
                row_index<passed_rois[SW[6:0]].roi_row_index+(temp/2)+(temp/4)+(temp/5)+(temp/20) &&
                col_index>passed_rois[SW[6:0]].roi_col_index+(temp/2)-(temp/20) &&
                col_index<passed_rois[SW[6:0]].roi_col_index+(temp/2)-(temp/20)+(temp/10))?(pixel_in&12'b0000_1111_0000):
                
                
                        /*(row_index>passed_rois[SW[7:0]].roi_row_index+165 && 
                        row_index<passed_rois[SW[7:0]].roi_row_index+205 &&
                        col_index>passed_rois[SW[7:0]].roi_col_index+90 &&
                        col_index<passed_rois[SW[7:0]].roi_col_index+110)?(pixel_in&12'b0000_1111_0000):*/
                        
                ((((row_index-passed_rois[SW[6:0]].roi_row_index) == passed_rois[SW[6:0]].roi_side_length>>1) || 
                  ((col_index-passed_rois[SW[6:0]].roi_col_index) == passed_rois[SW[6:0]].roi_side_length>>1))?
                  
                        /*(((col_index>220+shift_count && col_index<420+shift_count))?(12'h0bbf):(12'h0004)):
                        (((col_index>220+shift_count && col_index<420+shift_count))?(12'h0fbb):(12'h0400))):
                        ((col_index>220+shift_count && col_index<420+shift_count))?(12'h0fff):(12'h000);*/   
                        //centered square display logic
                
                (pixel_in&12'b0000_0000_1111):
                (pixel_in&12'b1111_0000_0000)):
                (row_index%20==0 || col_index%20==0)?(12'h00F):(pixel_in);
                   
        //end
        
    end
    
    /*always_comb begin
        if (row_index > passed_rois[0].roi_row_index &&
            row_index < passed_rois[0].roi_row_index + passed_rois[0].roi_side_length &&
            col_index > passed_rois[0].roi_col_index &&
            col_index < passed_rois[0].roi_col_index + passed_rois[0].roi_side_length)
            pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[1].roi_row_index &&
                row_index < passed_rois[1].roi_row_index + passed_rois[1].roi_side_length &&
                col_index > passed_rois[1].roi_col_index &&
                col_index < passed_rois[1].roi_col_index + passed_rois[1].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[2].roi_row_index &&
                row_index < passed_rois[2].roi_row_index + passed_rois[2].roi_side_length &&
                col_index > passed_rois[2].roi_col_index &&
                col_index < passed_rois[2].roi_col_index + passed_rois[2].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[3].roi_row_index &&
                row_index < passed_rois[3].roi_row_index + passed_rois[3].roi_side_length &&
                col_index > passed_rois[3].roi_col_index &&
                col_index < passed_rois[3].roi_col_index + passed_rois[3].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[4].roi_row_index &&
                row_index < passed_rois[4].roi_row_index + passed_rois[4].roi_side_length &&
                col_index > passed_rois[4].roi_col_index &&
                col_index < passed_rois[4].roi_col_index + passed_rois[4].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;      
        else if (row_index > passed_rois[5].roi_row_index &&
                row_index < passed_rois[5].roi_row_index + passed_rois[5].roi_side_length &&
                col_index > passed_rois[5].roi_col_index &&
                col_index < passed_rois[5].roi_col_index + passed_rois[5].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[6].roi_row_index &&
                row_index < passed_rois[6].roi_row_index + passed_rois[6].roi_side_length &&
                col_index > passed_rois[6].roi_col_index &&
                col_index < passed_rois[6].roi_col_index + passed_rois[6].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[7].roi_row_index &&
                row_index < passed_rois[7].roi_row_index + passed_rois[7].roi_side_length &&
                col_index > passed_rois[7].roi_col_index &&
                col_index < passed_rois[7].roi_col_index + passed_rois[7].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[8].roi_row_index &&
                row_index < passed_rois[8].roi_row_index + passed_rois[8].roi_side_length &&
                col_index > passed_rois[8].roi_col_index &&
                col_index < passed_rois[8].roi_col_index + passed_rois[8].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;   
        else if (row_index > passed_rois[9].roi_row_index &&
                row_index < passed_rois[9].roi_row_index + passed_rois[9].roi_side_length &&
                col_index > passed_rois[9].roi_col_index &&
                col_index < passed_rois[9].roi_col_index + passed_rois[9].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[10].roi_row_index &&
                row_index < passed_rois[10].roi_row_index + passed_rois[10].roi_side_length &&
                col_index > passed_rois[10].roi_col_index &&
                col_index < passed_rois[10].roi_col_index + passed_rois[10].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[11].roi_row_index &&
                row_index < passed_rois[11].roi_row_index + passed_rois[11].roi_side_length &&
                col_index > passed_rois[11].roi_col_index &&
                col_index < passed_rois[11].roi_col_index + passed_rois[11].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[12].roi_row_index &&
                row_index < passed_rois[12].roi_row_index + passed_rois[12].roi_side_length &&
                col_index > passed_rois[12].roi_col_index &&
                col_index < passed_rois[12].roi_col_index + passed_rois[12].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;      
        else if (row_index > passed_rois[13].roi_row_index &&
                row_index < passed_rois[13].roi_row_index + passed_rois[13].roi_side_length &&
                col_index > passed_rois[13].roi_col_index &&
                col_index < passed_rois[13].roi_col_index + passed_rois[13].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[14].roi_row_index &&
                row_index < passed_rois[14].roi_row_index + passed_rois[14].roi_side_length &&
                col_index > passed_rois[14].roi_col_index &&
                col_index < passed_rois[14].roi_col_index + passed_rois[14].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[15].roi_row_index &&
                row_index < passed_rois[15].roi_row_index + passed_rois[15].roi_side_length &&
                col_index > passed_rois[15].roi_col_index &&
                col_index < passed_rois[15].roi_col_index + passed_rois[15].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[16].roi_row_index &&
                row_index < passed_rois[16].roi_row_index + passed_rois[16].roi_side_length &&
                col_index > passed_rois[16].roi_col_index &&
                col_index < passed_rois[16].roi_col_index + passed_rois[16].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;    
        else if (row_index > passed_rois[17].roi_row_index &&
                row_index < passed_rois[17].roi_row_index + passed_rois[17].roi_side_length &&
                col_index > passed_rois[17].roi_col_index &&
                col_index < passed_rois[17].roi_col_index + passed_rois[17].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[18].roi_row_index &&
                row_index < passed_rois[18].roi_row_index + passed_rois[18].roi_side_length &&
                col_index > passed_rois[18].roi_col_index &&
                col_index < passed_rois[18].roi_col_index + passed_rois[18].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[19].roi_row_index &&
                row_index < passed_rois[19].roi_row_index + passed_rois[19].roi_side_length &&
                col_index > passed_rois[19].roi_col_index &&
                col_index < passed_rois[19].roi_col_index + passed_rois[19].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[20].roi_row_index &&
                row_index < passed_rois[20].roi_row_index + passed_rois[20].roi_side_length &&
                col_index > passed_rois[20].roi_col_index &&
                col_index < passed_rois[20].roi_col_index + passed_rois[20].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;      
        else if (row_index > passed_rois[21].roi_row_index &&
                row_index < passed_rois[21].roi_row_index + passed_rois[21].roi_side_length &&
                col_index > passed_rois[21].roi_col_index &&
                col_index < passed_rois[21].roi_col_index + passed_rois[21].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[22].roi_row_index &&
                row_index < passed_rois[22].roi_row_index + passed_rois[22].roi_side_length &&
                col_index > passed_rois[22].roi_col_index &&
                col_index < passed_rois[22].roi_col_index + passed_rois[22].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[23].roi_row_index &&
                row_index < passed_rois[23].roi_row_index + passed_rois[23].roi_side_length &&
                col_index > passed_rois[23].roi_col_index &&
                col_index < passed_rois[23].roi_col_index + passed_rois[23].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[24].roi_row_index &&
                row_index < passed_rois[24].roi_row_index + passed_rois[24].roi_side_length &&
                col_index > passed_rois[24].roi_col_index &&
                col_index < passed_rois[24].roi_col_index + passed_rois[24].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;   
        else if (row_index > passed_rois[25].roi_row_index &&
                row_index < passed_rois[25].roi_row_index + passed_rois[25].roi_side_length &&
                col_index > passed_rois[25].roi_col_index &&
                col_index < passed_rois[25].roi_col_index + passed_rois[25].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[26].roi_row_index &&
                row_index < passed_rois[26].roi_row_index + passed_rois[26].roi_side_length &&
                col_index > passed_rois[26].roi_col_index &&
                col_index < passed_rois[26].roi_col_index + passed_rois[26].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[27].roi_row_index &&
                row_index < passed_rois[27].roi_row_index + passed_rois[27].roi_side_length &&
                col_index > passed_rois[27].roi_col_index &&
                col_index < passed_rois[27].roi_col_index + passed_rois[27].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[28].roi_row_index &&
                row_index < passed_rois[28].roi_row_index + passed_rois[28].roi_side_length &&
                col_index > passed_rois[28].roi_col_index &&
                col_index < passed_rois[28].roi_col_index + passed_rois[28].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;      
        else if (row_index > passed_rois[29].roi_row_index &&
                row_index < passed_rois[29].roi_row_index + passed_rois[29].roi_side_length &&
                col_index > passed_rois[29].roi_col_index &&
                col_index < passed_rois[29].roi_col_index + passed_rois[29].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[30].roi_row_index &&
                row_index < passed_rois[30].roi_row_index + passed_rois[30].roi_side_length &&
                col_index > passed_rois[30].roi_col_index &&
                col_index < passed_rois[30].roi_col_index + passed_rois[30].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;       
        else if (row_index > passed_rois[31].roi_row_index &&
                row_index < passed_rois[31].roi_row_index + passed_rois[31].roi_side_length &&
                col_index > passed_rois[31].roi_col_index &&
                col_index < passed_rois[31].roi_col_index + passed_rois[31].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000;
        else if (row_index > passed_rois[32].roi_row_index &&
                row_index < passed_rois[32].roi_row_index + passed_rois[32].roi_side_length &&
                col_index > passed_rois[32].roi_col_index &&
                col_index < passed_rois[32].roi_col_index + passed_rois[32].roi_side_length)
                pixel = pixel_in&12'b1111_0000_0000; 
        else pixel = pixel_in;
    end*/

endmodule

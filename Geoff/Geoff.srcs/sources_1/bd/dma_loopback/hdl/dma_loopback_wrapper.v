//Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2016.2 (lin64) Build 1577090 Thu Jun  2 16:32:35 MDT 2016
//Date        : Tue Nov 29 22:00:38 2016
//Host        : brian-Inspiron-5547 running 64-bit Ubuntu 14.04.5 LTS
//Command     : generate_target dma_loopback_wrapper.bd
//Design      : dma_loopback_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps



module dma_loopback_wrapper
       (DDR_0_addr,
        DDR_0_ba,
        DDR_0_cas_n,
        DDR_0_ck_n,
        DDR_0_ck_p,
        DDR_0_cke,
        DDR_0_cs_n,
        DDR_0_dm,
        DDR_0_dq,
        DDR_0_dqs_n,
        DDR_0_dqs_p,
        DDR_0_odt,
        DDR_0_ras_n,
        DDR_0_reset_n,
        DDR_0_we_n,
        //FCLK_CLK0,
        //FCLK_RESET0_N,
        FIXED_IO_0_ddr_vrn,
        FIXED_IO_0_ddr_vrp,
        FIXED_IO_0_mio,
        FIXED_IO_0_ps_clk,
        FIXED_IO_0_ps_porb,
        FIXED_IO_0_ps_srstb,
        /*M_AXIS_MM2S_tdata,
        M_AXIS_MM2S_tkeep,
        M_AXIS_MM2S_tlast,
        M_AXIS_MM2S_tready,
        M_AXIS_MM2S_tvalid,
        S_AXIS_S2MM_tdata,
        S_AXIS_S2MM_tkeep,
        S_AXIS_S2MM_tlast,
        S_AXIS_S2MM_tready,
        S_AXIS_S2MM_tvalid,*/
        BTNC, BTNR, BTNL, BTNU, BTND,
        SW,
        VGA_R, VGA_G, VGA_B, VGA_HS, VGA_VS,
        LED);
    inout [14:0]DDR_0_addr;
    inout [2:0]DDR_0_ba;
    inout DDR_0_cas_n;
    inout DDR_0_ck_n;
    inout DDR_0_ck_p;
    inout DDR_0_cke;
    inout DDR_0_cs_n;
    inout [3:0]DDR_0_dm;
    inout [31:0]DDR_0_dq;
    inout [3:0]DDR_0_dqs_n;
    inout [3:0]DDR_0_dqs_p;
    inout DDR_0_odt;
    inout DDR_0_ras_n;
    inout DDR_0_reset_n;
    inout DDR_0_we_n;
    //output FCLK_CLK0;
    //output FCLK_RESET0_N;
    inout FIXED_IO_0_ddr_vrn;
    inout FIXED_IO_0_ddr_vrp;
    inout [53:0]FIXED_IO_0_mio;
    inout FIXED_IO_0_ps_clk;
    inout FIXED_IO_0_ps_porb;
    inout FIXED_IO_0_ps_srstb;
    //user-added
    input BTNC, BTNR, BTNL, BTNU, BTND;
    input [7:0] SW;
    output [3:0] VGA_B, VGA_G, VGA_R;
    output VGA_HS, VGA_VS;
    output reg [7:0] LED;
    /*output [31:0]M_AXIS_MM2S_tdata;
    output [3:0]M_AXIS_MM2S_tkeep;
    output M_AXIS_MM2S_tlast;
    input M_AXIS_MM2S_tready;
    output M_AXIS_MM2S_tvalid;
    input [31:0]S_AXIS_S2MM_tdata;
    input [3:0]S_AXIS_S2MM_tkeep;
    input S_AXIS_S2MM_tlast;
    output S_AXIS_S2MM_tready;
    input S_AXIS_S2MM_tvalid;*/

    wire [14:0]DDR_0_addr;
    wire [2:0]DDR_0_ba;
    wire DDR_0_cas_n;
    wire DDR_0_ck_n;
    wire DDR_0_ck_p;
    wire DDR_0_cke;
    wire DDR_0_cs_n;
    wire [3:0]DDR_0_dm;
    wire [31:0]DDR_0_dq;
    wire [3:0]DDR_0_dqs_n;
    wire [3:0]DDR_0_dqs_p;
    wire DDR_0_odt;
    wire DDR_0_ras_n;
    wire DDR_0_reset_n;
    wire DDR_0_we_n;
    wire FCLK_CLK0;
    wire FCLK_RESET0_N;
    wire FIXED_IO_0_ddr_vrn;
    wire FIXED_IO_0_ddr_vrp;
    wire [53:0]FIXED_IO_0_mio;
    wire FIXED_IO_0_ps_clk;
    wire FIXED_IO_0_ps_porb;
    wire FIXED_IO_0_ps_srstb;
    
    wire [7:0]SW;
    

  wire [31:0]M_AXIS_MM2S_tdata;
  wire [3:0]M_AXIS_MM2S_tkeep;
  wire M_AXIS_MM2S_tlast;
  wire M_AXIS_MM2S_tready;
  wire M_AXIS_MM2S_tvalid;

  wire [31:0]S_AXIS_S2MM_tdata;
  wire [3:0]S_AXIS_S2MM_tkeep;
  wire S_AXIS_S2MM_tlast;
  wire S_AXIS_S2MM_tready;
  wire S_AXIS_S2MM_tvalid;

  dma_loopback dma_loopback_i
       (.DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .FCLK_CLK0(FCLK_CLK0),
        .FCLK_RESET0_N(FCLK_RESET0_N),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .M_AXIS_MM2S_tdata(M_AXIS_MM2S_tdata),
        .M_AXIS_MM2S_tkeep(M_AXIS_MM2S_tkeep),
        .M_AXIS_MM2S_tlast(M_AXIS_MM2S_tlast),
        .M_AXIS_MM2S_tready(M_AXIS_MM2S_tready),
        .M_AXIS_MM2S_tvalid(M_AXIS_MM2S_tvalid),
        .S_AXIS_S2MM_tdata(S_AXIS_S2MM_tdata),
        .S_AXIS_S2MM_tkeep(S_AXIS_S2MM_tkeep),
        .S_AXIS_S2MM_tlast(S_AXIS_S2MM_tlast),
        .S_AXIS_S2MM_tready(S_AXIS_S2MM_tready),
        .S_AXIS_S2MM_tvalid(S_AXIS_S2MM_tvalid));

    //vga interface
    logic [11:0] pixel;
    logic [9:0]  row_index , col_index;
    logic blanktemp;
    logic [18:0] integral_addr;
    
    parameter READ_CHANS=1;
    logic we_image, we_int, DMA_slave_ready, count_reset, frame_ready, image_done;
    logic [16:0] w_addr, w_addr_counter;
    logic [16:0] r_addr;
    logic [15:0] data_out;
    logic [15:0] data_in_im;
    logic [31:0] data_in;
    logic [16:0] int_out_disp, int_out;
    logic [3:0] data_out_byte;
    logic [16:0] address;
    logic [16:0] r_addr_reg;
    logic frame_ready_reg, frame_ready_reg_2, frame_ready_reg_3;
    
    logic clk_50;
    
    always_ff @(posedge FCLK_CLK0) begin
        clk_50 <= ~clk_50;
    end
    
    /* Processing Pipeline */
   
    CHIP_INTERFACE feature_pipeline(
                 //FCLK0_CLK0 is 50 MHz
                 .GCLK(FCLK_CLK0),
                 .BTNC(BTNC),.BTNL(BTNL),.BTNR(BTNR),.BTNU(BTNU),.BTND(BTND),
                 .SW(SW), .pixel_in(pixel),
                 .VGA_R(VGA_R), .VGA_G(VGA_G), .VGA_B(VGA_B),
                 .LED(LED),
                 .VGA_VS(VGA_VS), .VGA_HS(VGA_HS),
                 .row_index(row_index), .col_index(col_index), 
                 //integral image address/data
                 .integral_pixel(int_out) ,
                 .integral_mem_addr(integral_addr)
                 );     

    enum logic [1:0] {bram_write_int = 2'b00, bram_write_image = 2'b01, 
                      bram_read = 2'b10} memState, nextMemState;
    
    //state register
    always_ff @(posedge FCLK_CLK0, negedge FCLK_RESET0_N) begin
        if (~FCLK_RESET0_N) memState <= bram_write_int; //default to updating frame
        else memState <= nextMemState;
    end
    
    //write address register - vivado doesn't like async reset
    always_ff @(posedge FCLK_CLK0) begin
        if (~FCLK_RESET0_N || count_reset) w_addr_counter <= 0;
        //32 bit transfers at a time
        else if (we_int || we_image) w_addr_counter <= w_addr_counter + 1;
        else w_addr_counter <= w_addr_counter;
    end
    
    logic [7:0] LED_hit;

    
    always_ff @(posedge FCLK_CLK0, negedge FCLK_RESET0_N) begin
        if (~FCLK_RESET0_N) r_addr_reg <= 19'b0;
        else r_addr_reg <= r_addr;
    end
    

    always_ff @(posedge FCLK_CLK0) begin
        if (~FCLK_RESET0_N) frame_ready_reg <= 1'b0;
        else begin 
            frame_ready_reg <= frame_ready;
            frame_ready_reg_2 <= frame_ready_reg;
            frame_ready_reg_3 <= frame_ready_reg_2;
        end
    end
    
        
    //next state and output logic
    always_comb begin
        w_addr = 15'b0; address = 15'b0;
        count_reset = 1'b0;
        we_image = 1'b0; DMA_slave_ready = 1'b0;
        we_int = 1'b0;
        LED_hit = 7'b0;
        r_addr = ((col_index>>1) + (320*(row_index>>1)));
        frame_ready = 1'b0; 
        nextMemState = bram_write_int;
        data_in = 32'b0; data_in_im = 4'b0;
        case(memState)
            bram_write_int: begin
                //only the master needs to be valid. We are always ready.
                DMA_slave_ready = 1'b1; count_reset = 1'b0;
                we_int = M_AXIS_MM2S_tvalid;
                //w_addr = w_addr_counter;
                address = w_addr_counter[16:0];
                pixel = {3{data_out_byte}};
                //else pixel = {3{int_out_disp[16:13]}};
                //next state logic
                data_in = M_AXIS_MM2S_tdata;
                nextMemState = (M_AXIS_MM2S_tlast) ? bram_write_image : bram_write_int;
                if (nextMemState == bram_write_image) begin
                    count_reset = 1'b1;
                    frame_ready = 1'b1;
                end
                LED_hit[0] = 1'b1;
            end
            bram_write_image: begin
                if (w_addr_counter < 5) begin 
                    frame_ready = 1'b1;
                end
                else frame_ready = 1'b0;
                //only the master needs to be valid. We are always ready.
                DMA_slave_ready = 1'b1; count_reset = 1'b0;
                we_image = M_AXIS_MM2S_tvalid;
                //start reading the integral image for displaying
                w_addr = w_addr_counter;
                //address = w_addr_counter[16:0];
                //also read the integral image for processing
                pixel = {3{data_out_byte}};
                //else pixel = {3{int_out_disp[16:13]}};
                //next state logic
                data_in_im = {M_AXIS_MM2S_tdata[31:28], M_AXIS_MM2S_tdata[23:20], M_AXIS_MM2S_tdata[15:12], M_AXIS_MM2S_tdata[7:4]};
                nextMemState = (M_AXIS_MM2S_tlast) ? bram_read : bram_write_image;
                if (nextMemState == bram_read) count_reset = 1'b1;
                LED_hit[1] = 1'b1;    
            end
            bram_read: begin
                DMA_slave_ready = 1'b0; we_int = 1'b0; we_image = 1'b0;
                address = integral_addr; 

                pixel = {3{data_out_byte}};
                //else pixel = {3{int_out_disp[16:13]}};
                //next state logic
                nextMemState = (M_AXIS_MM2S_tvalid && col_index == 'd600 && row_index == 'd400) ? bram_write_int : bram_read;
                if (nextMemState == bram_write_int) count_reset = 1'b1;
                LED_hit[2] = 1'b1;
            end
            default: begin
                LED_hit[2] = 1'b0;
            end
        endcase
    end
              

    //17 bits of integral image                           
    reg_ram #(.BITS(17)) bram_int_lo(.clk(FCLK_CLK0), .we(we_int), .w_addr(address), 
                          .r_addr(address), .integral_addr(integral_addr), .d_in(data_in[16:0]), 
                          .d_out(int_out_disp), .d_out_int(int_out[16:0]));
    
   
    //4 bit greyscale image
    v_ram bram_image(.clk(FCLK_CLK0), .we(we_image), .w_addr(w_addr), 
                      .r_addr(r_addr[16:2]), .d_in(data_in_im), 
                      .d_out(data_out));
   
  
    
    /* get the byte of the memory word we want */
    always_comb begin
        case((r_addr_reg[1:0]))
            2'b00: begin
                data_out_byte = {1{data_out[3:0]}};
            end
            2'b01: begin
                data_out_byte = {1{data_out[7:4]}};
            end
            2'b10: begin
                data_out_byte = {1{data_out[11:8]}};
            end
            2'b11: begin 
                data_out_byte = {1{data_out[15:12]}};
            end
        endcase
    end
     
    //DMA loopback for now 
           //master-to-slave
    assign S_AXIS_S2MM_tdata = M_AXIS_MM2S_tdata,
           S_AXIS_S2MM_tkeep = M_AXIS_MM2S_tkeep, //should always remain high
           S_AXIS_S2MM_tlast = M_AXIS_MM2S_tlast,
           S_AXIS_S2MM_tvalid = M_AXIS_MM2S_tvalid;
           //slave-to-master
    assign M_AXIS_MM2S_tready = DMA_slave_ready;
                           
endmodule


/*
 * Integral Image
 */
module reg_ram (clk, we, w_addr, r_addr, integral_addr, d_in, d_out, d_out_int);
    
    parameter MEM_SIZE = 76800;
    parameter BITS = 17;

    input clk;
    input we;
    //only one write port
    input [16:0] w_addr;
    input [BITS-1:0] d_in;
    //reading
    input [16:0] r_addr;
    input [16:0] integral_addr;
    output reg [BITS-1:0] d_out;
    output reg [BITS-1:0] d_out_int;
    
    reg [BITS-1:0] ram [MEM_SIZE-1:0]; //2^19
    
    //writing fsm
    always @(posedge clk) begin
        if (we)
            ram[w_addr] <= d_in;
        d_out <= ram[r_addr];
        d_out_int <= ram[integral_addr];
    end
  
endmodule


/* 
* Configured to hold 307,200 4-bit pixels (gray)
*/
module v_ram (clk, we, w_addr, r_addr, d_in, d_out);
    /* 32 bit write, 32 bit read */
    //parameter READ_WIDTH = 32;
    parameter MEM_SIZE = 19200; //76800 rows of 4 pixels
    //parameter MEM_WIDTH = 1; //number of bytes per pixel
    input clk;
    input we;
    //only one write port
    input [14:0] w_addr;
    input [15:0] d_in;
    //reading
    input [14:0] r_addr;// [NUM_PORTS-1:0]; //address array
    output reg [15:0] d_out;// [NUM_PORTS-1:0]; //data array
    
    reg [15:0] ram [MEM_SIZE-1:0]; //2^19
    
    //writing fsm
    always @(posedge clk) begin
        if (we)
            ram[w_addr] <= d_in;
        d_out <= ram[r_addr];
    end
  
endmodule
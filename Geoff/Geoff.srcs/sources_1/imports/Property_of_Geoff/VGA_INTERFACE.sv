module VGA_INTERFACE
   (input  logic GCLK,
    input  logic rst_b,
    input  logic [11:0] pixel,
    output logic [3:0] VGA_R, VGA_G, VGA_B,
    output logic VGA_VS, VGA_HS,
    output logic [9:0] row_index, 
    output logic [9:0] col_index);

    logic clk;
    logic [8:0] row;
    logic [9:0] col;
   
    assign row_index = {1'b0 , row};
    assign col_index = col;

    vga (.reset(~rst_b), .HS(VGA_HS), .VS(VGA_VS), .blank(blanktemp), .CLOCK_50(clk), .row(row), .col(col));
    
    always_ff @(posedge GCLK) begin
        {VGA_R, VGA_G, VGA_B} = (blanktemp == 1) ? 12'h0 : pixel;
    end
    
    always_ff @(posedge GCLK) begin
        clk <= ~clk;
    end
    
endmodule: VGA_INTERFACE

module distance_mod (
    input  logic [11:0] a, b,
    input  logic clk,
    input  logic [11:0] distance,
    output logic is_within);
    
    logic [22:0] ta,tb, tdistance;
    assign ta = {11'd0,a};
    assign tb = {11'd0,b};
    assign tdistance = {11'd0,distance};
    
    assign is_within = (((ta*ta) + (tb*tb)) / tdistance) <= tdistance;
    
endmodule: distance_mod  

module clk_div(
    input logic clk_in, reset_n,
    output logic clk_out); //out will be 1/4 in
    
    logic [1:0] counter;
    logic rollovers;
    
    always_ff @(posedge clk_in, negedge reset_n) begin
        if (~reset_n) begin 
            counter <= 0;
            rollovers <= 0;
        end
        else begin 
            clk_out <= clk_out + 1; 
        end
    end
     
endmodule     

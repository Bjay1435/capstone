%take the image in img.jpg, convert it to black and white, compute the
%integral image of that black and white image, and then convert those 
%integral values to 17 bits to be written to the coe file. 17 bits is the
%necessary amount for a one bit image with size 320*240

img = imread('img.jpg');
fid = fopen('integral_img.coe','w');
img2 = uint32(zeros(480,640,3));
temp_colors = uint32(zeros(1,3));
fprintf(fid,'memory_initialization_radix=16;\n');
fprintf(fid,'memory_initialization_vector=\n');
for row=1:1:240
   for col=1:1:320
      for color=1:1:3
         temp = dec2bin(sum(sum(uint32(bitshift(img(1:2:row*2,1:2:col*2,color),-7) & hex2dec('80')))));
         temp = [zeros(1,17-length(temp)) temp];
         img2(row,col,color) = bin2dec(temp(1:17));
         temp_colors(color) = bin2dec(temp(1:17));
      end
      grey_pix = uint32(sum(temp_colors)/3);
      if (~((row == 240) && (col == 320))) 
          fprintf(fid,'%05x,\n',grey_pix); 
      else
          fprintf(fid,'%05x;',grey_pix);
      end
   end
end
fclose(fid);
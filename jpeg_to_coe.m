%transfer the contents of the 640*480 image in img.jpg to a coe file in the
%form of a 4 bit grayscale image of size 320*240, with one pixel per line

img = imread('img.jpg');
fid = fopen('img.coe','w');
pixels = uint8(zeros(320,240,3));
fprintf(fid,'memory_initialization_radix=16;\n');
fprintf(fid,'memory_initialization_vector=\n');
for row=1:1:240
   for col=1:1:320
      for color=1:1:3
          pixel = img(2*row,2*col,color);
          pixels(row,col,color) = pixel; 
      end
      grey_pix = uint8(sum(pixels(row,col,:)/3));
      if (~((row == 240) && (col == 320))) 
          fprintf(fid,'%02x,\n',grey_pix); 
      else
          fprintf(fid,'%02x;',grey_pix);
      end
   end
end

grey_pixels = uint8(zeros(320,240,3));
for row=1:1:240
    for col=1:1:320
        grey_pixels(row,col,1) = uint8(sum(pixels(row,col,:))/3);
        grey_pixels(row,col,2) = uint8(sum(pixels(row,col,:))/3);
        grey_pixels(row,col,3) = uint8(sum(pixels(row,col,:))/3);
    end
end

fclose(fid);
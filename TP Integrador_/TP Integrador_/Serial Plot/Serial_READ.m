function [ voltage , buffer_index ] = Serial_READ(s,N)
fwrite(s,1)
data = fread(s,N+1,'uint8');
buffer_index = data(1);
voltage=data(2:end)*5/255;
end
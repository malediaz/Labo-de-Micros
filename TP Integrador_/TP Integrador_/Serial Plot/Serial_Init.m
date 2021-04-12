function [s] = Serial_Init(N)
instrreset

port = 'COM3';
s=serial(port,'BaudRate', 9600,'InputBufferSize',2*N);
fopen(s);
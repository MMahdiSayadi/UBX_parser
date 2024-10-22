clc 
clear 
close all 
addpath('fcn\');
addpath("Dataset\");


read_filename = 'UBX_LOG.ubx';
write_filename = 'Mat_Out_UBXUBX_00_Real.txt';
writePath = '../HW/SRC/TB/TestFiles/';
[o, o_bin] = ubx_reader(read_filename);


writeKey = 1;
if writeKey 
    write2file([writePath, write_filename], o_bin);
    disp('write success!!');
end 


















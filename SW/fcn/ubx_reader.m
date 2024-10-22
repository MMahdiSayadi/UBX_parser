function [o, o_bin] = ubx_reader(path)
    fileID = fopen(path, 'rb');
    data = fread(fileID, 'uint8');
    fclose(fileID);
    data_bin = dec2bin(data);
    o = data;
    o_bin = data_bin;
end 
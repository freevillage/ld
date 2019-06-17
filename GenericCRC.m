function crc = GenericCRC(input)


% crc = generic_crc(input)
%
% input = vector of 16 bit data
%
% crc = Cyclic Redundancy Check of data
%


% Initialise syndrome to all ones
syndrome = uint16(hex2dec('ffff'));


% Seperate data into MSByte and LSByte
data = zeros([2*length(input) 1]);
data(1:2:end) = bitshift( bitand(input,hex2dec('FF00')),-8 );
data(2:2:end) = bitand(input,hex2dec('00FF'));
data = uint16(data);


% Calculate CRC
for n = 1:length(data)
    syndrome = ByteCRC(data(n),syndrome);
end


crc = syndrome;

end


% function to calculate the serial CRC of a byte
function op = ByteCRC(inbyte,insyn)


temp = bitxor(bitshift(insyn,-8),inbyte);
insyn = bitshift(insyn,8);
quick = bitxor( temp,bitshift(temp,-4) );
insyn = bitxor(insyn,quick);
quick = bitshift(quick,5);
insyn = bitxor(insyn,quick);
quick = bitshift(quick,7);
op = bitxor(insyn,quick);

end
function matlabArray = readBinaryFile( binFilename, format )

if nargin < 2
    format = 'float32';
end

binFileID = FileOpen( binFilename, 'r' );
matlabArray = fread( binFileID, format );
FileClose( binFileID );

end
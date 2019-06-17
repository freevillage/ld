function writeBinaryFile( binFilename, matlabArray, format )

if nargin < 3
    format = 'float32';
end

binFileID = fopen( binFilename, 'w' );
fwrite( binFileID, transpose( matlabArray ), format );
fclose( binFileID );

end % of writeSufile
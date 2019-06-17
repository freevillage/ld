function fileID = FileOpen( filename, varargin )

assert( ischar( filename ), 'Invalid file name. Must be a string!' );

fileID = fopen( filename, varargin{:} );
if fileID == -1
    error( 'Could not open file!' );
end

end





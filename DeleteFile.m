function DeleteFile( varargin )
if( nargin == 0 )
    error ( 'Must specify at least one file to be deleted!' );
end

for FileNumber = 1 : nargin
    CurrentFilename = varargin{ FileNumber };
    if( ~ischar( CurrentFilename ) )
        error( 'Filenames must be strings!' );
    elseif( exist( CurrentFilename, 'file' ) )
        delete( CurrentFilename );
    end
end

end
function SaveMat( filename, version )

if nargin < 2
    version = '-v7.3';
end

matlabExtension = '.mat';

if ~strcmp( FileExtension( filename ), matlabExtension )
    filename = [ filename, matlabExtension ];
end

saveCommand = sprintf( 'save( ''%s'', ''-mat'', ''%s'' )', filename, version );

evalin( 'base', saveCommand );

end
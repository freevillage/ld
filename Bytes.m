function Bytes( variable ) %#ok<INUSD>
% Bytes writes the memory usage of the provided variable 

units = { 'B', 'KB', 'MB', 'GB', 'TB', 'PB' };
maxScale = length( units ) - 1;
bytesPerUnit = 1024 .^ (0:maxScale);

variableInfo = whos( 'variable' );
variableSize = variableInfo.bytes;
sizeScale = floor( log( variableSize ) / log( 1024 ) );

sizeNotAvailable = (sizeScale == -inf);
sizeWithinRange = (sizeScale >= 0 && sizeScale <= maxScale);
sizeTooBig = (sizeScale > maxScale);

assert( sizeNotAvailable || sizeWithinRange || sizeTooBig );

if sizeNotAvailable
    string = 'Size is not available';
elseif sizeWithinRange
    string = [ sprintf( '%.0f', variableSize / bytesPerUnit(sizeScale+1) ), units{sizeScale+1} ];
elseif sizeTooBig
    string = 'Size is too big';
else
    string = 'Error';
end

disp( string );

end
    

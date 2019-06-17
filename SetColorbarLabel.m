function SetColorbarLabel( newLabel )

assert( ischar( newLabel ), 'SetColorLabel:InvalidInput', 'The label must be a string' );

colorbarHandle = colorbar;
colorbarYLabel = get( colorbarHandle, 'ylabel' );
set( colorbarYLabel, 'string', newLabel );

end % of function SetColorbarLabel
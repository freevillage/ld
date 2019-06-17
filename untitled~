function varargout = FindMinimum( x, y )

[yMin, indexMin] = min( y );
xMin = x(indexMin);

if nargout < 2
    varargout{1} = yMin;
elseif nargout == 2
    varargout{1} = xMin;
    varargout{2} = yMin;
else
    error( 'Number of outputs should be <= 2' );
end

end
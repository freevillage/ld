function minmax = MinMaxExpanded( array, extension )

if nargin < 2, extension = 0; end
extensionLength = length( extension );

assert( isnumeric( extension ) && ( extensionLength == 1 || extensionLength == 2 ) );
if isscalar( extension ), extension = [ extension, extension ]; end

aMin = min( ToColumn( array ) );
aMax = max( ToColumn( array ) );

minmax = [ aMin - extension(1), aMax + extension(2) ];

end
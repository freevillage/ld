function mm = MinMaxScaled( a, s )

amin = min( a(:) );
amax = max( a(:) );

if nargin < 2, s = 0; end

delta = s * ( amax - amin );

mm = [ amin-delta, amax+delta ];

end
function flag = IsLinspace( array )
%ISLINSPACE(A) returns true if A is an equally spaced array and
%false otherwise
%
%Examples:
%   ISLINSPACE([1 2 3 4 5]) returns true
%   ISLINSPACE([1 2.1 4.2 5.2]) returns false
%
% See also:
%   LINSPACE

% Copyright 2013/1/20 Oleg V. Poliannikov (oleg.poliannikov@gmail.com)

reference = MatchingLinspace( array );
flag = all( abs( array-reference ) <= abs( reference .* 1e-10 ) );

end
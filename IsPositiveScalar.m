function flag = IsPositiveScalar( input )
%ISPOSITIVESCALAR(A) returns true if A is a positive scalar and false
%otherwise
%
%Examples:
%   ISPOSITIVESCALAR(5) returns true because 5 is a positive number
%   ISPOSITIVESCALAR(ones(5)) returns false because the input is a 5x5
%   matrix
%
% See also:
%   ISNUMERIC, ISSCALAR

% Copyright 2012/12/28 Oleg V. Poliannikov
% Oleg.Poliannikov@gmail.com

flag = isnumeric( input ) && isscalar( input ) && ( input > 0 );

end


function flag = IsIntegerNumber( input )
%ISINTEGERNUMBER(A) returns true if A consists of integer numbers and
%false otherwise
%
%Examples:
%   IsIntegerNumber(5.4) returns false because 5.4 is not an integer
%   IsIntegerNumber(ones(5)) returns true because the input is a 5x5
%   matrix of integer numbers
%
% Note that this function does not require that the input be of integer
% class, just that the fractional part is zero
%
% See also:
%   ISINTEGER, ISPOSITIVEINTEGER

% Copyright 2012/12/28 Oleg V. Poliannikov

flag = ~isempty(input) ...
    && isnumeric(input) ...
    && isreal(input) ...
    && all(isfinite(input)) ...
    && all(input == fix(input));

end


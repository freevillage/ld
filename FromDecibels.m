function xLinear = FromDecibels( xDb, xRef )

if nargin < 2, xRef = 1; end

xLinear = xRef .* 10 .^ (xDb/10);

end
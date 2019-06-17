function yesno = IsGraphAxis( input )
%ISGRAPHAXIS(A) returns true if A is of class GraphAxis and false
%otherwise
%
%Examples:
%   ISGRAPHAXIS(GraphAxis(1:10,'Step','#')) returns true
%   ISGRAPHAXIS(1:10) returns false
%
% See also:
%   ISA

% Copyright 2013/1/20 Oleg V. Poliannikov
% Oleg.Poliannikov@gmail.com

yesno = isa( input, 'GraphAxis' );

end


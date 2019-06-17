function flag = IsLogicalScalar( input )
%ISLOGICALSCALAR(A) returns true if A is a single logical
% variable, and false otherwise
%
%EXamples:
%   ISLOGICALSCALAR( true ) returns true
%   ISLOGICALSCALAR( [1 1] ) returns false because [1 1] is
% neither a scalar nor a logical variable
%
% See also:
%   ISLOGICAL

% Copyright 2013/1/20 Oleg V. Poliannikov
% Oleg.Poliannikov@gmail.com

flag = isscalar( input ) && islogical( input );

end
function yesno = IsProbability( array )
%ISPROBABILITY(A) returns true if A consists of real numbers between 0 and
%1, and false otherwise.
%
%Example:
%   IsProbability( [0 0.5 1] ) returns true because all numbers are valid
%   probability values
%
% See also:
%   ISNUMERIC, ISREAL

% (C) 2013 Oleg V. Poliannikov (oleg.poliannikov@gmail.com)
% $Revision: 1.0.0.0 $  $Date: 2013/02/22 10:31:00 $

yesno = isnumeric( array ) ...
    && isreal( array ) ...
    && all( array >= 0.0 & array <= 1.0 );

end
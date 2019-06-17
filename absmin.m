function [minValue,minIndex] = absmin( array )
%ABSMIN(A) returns the single smallest value in the array.
%
%[M,I] = ABSMIN(A) returns the linear index of the smallest element.
%
% See also:
%   max, absmax, ind2sub

% Copyrights 2013 Oleg V. Poliannikov (oleg.poliannikov@gmail.com)
% $Revision: 2.0.0.0 $Data: 2013/02/24 14:51:00 $

[minValue, minIndex] = min( array(:) );

end
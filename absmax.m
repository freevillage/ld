function [maxValue,maxIndex] = absmax( array )
%ABSMAX(A) returns the single largest value in the array.
%
%[M,I] = ABSMAX(A) returns the linear index of the largest element.
%
% See also:
%   max, absmin, ind2sub

% Copyrights 2013 Oleg V. Poliannikov (oleg.poliannikov@gmail.com)
% $Revision: 2.0.0.0 $Data: 2013/02/24 14:25:00 $

[maxValue, maxIndex] = max( array(:) );
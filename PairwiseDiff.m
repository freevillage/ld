%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                             %
% PAIRWISE VECTOR DIFFERENCE                                                  %
%  (c) 2009 Joseph Rushton Wakeling                                           %
%                                                                             %
%  Special thanks to Jaroslav Hajek for suggesting these implementations      %
%  for efficient pairwise vector diff calculation.                            %
%                                                                             %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This function calculates the pairwise differences between the columns of a
% given matrix X, returning a 3D matrix D such that
%
%     D(:,i,j) = X(:,i) - X(:,j)
%
function D = PairwiseDiff( X )

[totalRows, totalCols] = size( X );

if exist( 'bsxfun', 'builtin' )
    D = bsxfun( @minus, X, reshape( X, totalRows, 1, totalCols ) );
else
    XX = reshape( X, totalRows, 1, totalCols );
    D = X( :, :, ones( 1, totalCols ) )  -  XX(:, ones( 1, totalCols ), :);
end

end

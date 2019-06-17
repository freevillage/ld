function [contourMatrixOut, contourGroupOut] = ShowConfidenceContour( x, y, pdf, confidenceLevel, varargin )

%% Check the validity of the input and output
%  No invalid input is allowed under any circumstances

assert( isvector( x ) && isreal( x ) ...
    && isvector( y ) && isreal( y ) ...
    && ismatrix( pdf ) && isreal( pdf ) ...
    && isscalar( confidenceLevel ) ...
    && IsProbability( confidenceLevel ) ...
    && size( pdf, 1 ) == length( x ) ...
    && size( pdf, 2 ) == length( y ) );

assert( nargout <= 2, 'ShowConfidenceContour:TooManyOutputs', ...
    'Too many output arguments' );

isContourMatrixRequested = nargout > 0;
isContourGroupRequested  = nargout > 1;

%% Build the contour

contourLevel(1:2) = FindConfidenceContourLevel( x, y, pdf, confidenceLevel );
[contourMatrix, contourGroup] = contour( x, y, pdf, contourLevel, varargin{:} );

%% Assign output as requested

if isContourMatrixRequested
    contourMatrixOut = contourMatrix;
end
if isContourGroupRequested
    contourGroupOut = contourGroup;
end

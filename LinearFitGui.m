function [slope, interceptAtX0] = LinearFitGui( gather, x0 )

assert( IsDataset( gather ) && ismatrix( gather ) );
if nargin < 2 
    x0 = gather.Axes(1).Min;
end

figure( 'Name', 'Best linear fit' );
DisplayGather( gather );
[ xPressed, yPressed ] = ginput( 2 );
[slope, intercept] = TwoPointsToLinearFcn( xPressed(1), yPressed(1), xPressed(2), yPressed(2) );
linearFcn = @(x) slope*x + intercept;
interceptAtX0 = linearFcn( x0 );

end


function [slope, intercept] = TwoPointsToLinearFcn( x1, y1, x2, y2 )

assert( x1 ~= x2 );

slope = (y2 - y1) / (x2 - x1);
intercept = (x2*y1 - x1*y2) / (x2 - x1);

end


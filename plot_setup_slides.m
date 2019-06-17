SetDefaultFigureProperties

sourceLocation = [ 0, 0, 0 ];
receiverLocation = [-400, 0, 3000 ];

    
figure( 'Visible', 'On' ), hold on

line( [ 0 -400 ], [ 0 0 ], [ 0 3000 ], 'Color', 'b' )

plot3( 0, 0, 0, 'rp', 'MarkerFaceColor', 'r' )
plot3( -400, 0.00, 3000, 'g^', 'MarkerFaceColor', 'g' )

legend( 'Line of sight', 'Tower', 'Platform' )

xlabel( 'Easting [m]' )
ylabel( 'Northing [m]' )
zlabel( 'Altitude [m]' )
title( 'Basic setup' )

axis( [ -1000, 1000, -1000, 1000, 0, 3000 ] )

grid on

view( 3 )

arrayPosition = [ 0 ; 0 ; 0 ];
lx = 1;
ly = 1;
Nx = 5;
Ny = 11;

alpha = 0;
beta  = 0;
gamma = 0 ;

receiverPosition = UniformRectangularArray( [lx ly], [Nx Ny], arrayPosition, [alpha, beta, gamma] );

plot3( ToColumn(receiverPosition(1,:,:)), ToColumn(receiverPosition(2,:,:)), ToColumn(receiverPosition(3,:,:)), ...
    'g^', 'MarkerFaceColor', 'g' );
xlabel( 'x' ), ylabel( 'y' ), zlabel( 'z' ), title( 'Receiver array' );
%set( gca, 'XDir', 'Reverse', 'YDir', 'Reverse' );
view( [-37 30] )
axis( [-1 1 -1 1 -1 1] )
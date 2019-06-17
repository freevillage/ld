function posReceiver = UniformRectangularArray( arrayDimensions, totalReceivers, arrayPosition, rotationDescription )

assert( isvector( arrayDimensions ) && all( arrayDimensions > 0 ) && length( arrayDimensions ) == 2 );
lx = arrayDimensions(1);
ly = arrayDimensions(2);

assert( isvector( totalReceivers ) && all( totalReceivers > 0 ) && length( totalReceivers ) == 2 );
totalReceivers = round( totalReceivers );
Nx = totalReceivers(1);
Ny = totalReceivers(2);

assert( isvector( arrayPosition ) && isreal( arrayPosition ) && length( arrayPosition ) == 3 );

assert( ( isvector( rotationDescription ) && isreal( rotationDescription ) && length( rotationDescription ) == 3 ) ...
    || ( ismatrix( rotationDescription ) ) );

if isvector( rotationDescription )
    alpha = rotationDescription(1);
    beta = rotationDescription(2);
    gamma = rotationDescription(3);
    rotationMatrix = RotationMatrix( alpha, beta, gamma );
else
    rotationMatrix = rotationDescription;
end

dx = lx / (Nx-1);
dy = ly / (Ny-1);

xi = dx * ( 0 : Nx-1 ) - lx/2;
yj = dy * ( 0 : Ny-1 ) - ly/2;

[X, Y, Z] = ndgrid( xi, yj, 0 );

xyzRot = rotationMatrix * [ ToRow( X ); ToRow( Y ); ToRow( Z ) ];

Xtranslated = xyzRot(1, :) + arrayPosition(1);
Ytranslated = xyzRot(2, :) + arrayPosition(2);
Ztranslated = xyzRot(3, :) + arrayPosition(3);

posReceiver = reshape( [Xtranslated ; Ytranslated ; Ztranslated], [3 Nx Ny] );

end
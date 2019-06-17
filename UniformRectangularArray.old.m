function posReceiver = UniformRectangularArray( arrayDimensions, totalReceivers, arrayPosition, arrayAngles )

assert( isvector( arrayDimensions ) && all( arrayDimensions > 0 ) && length( arrayDimensions ) == 2 );
lx = arrayDimensions(1);
ly = arrayDimensions(2);

assert( isvector( totalReceivers ) && all( totalReceivers > 0 ) && length( totalReceivers ) == 2 );
totalReceivers = round( totalReceivers );
Nx = totalReceivers(1);
Ny = totalReceivers(2);

assert( isvector( arrayPosition ) && isreal( arrayPosition ) && length( arrayPosition ) == 3 );

assert( isvector( arrayAngles ) && isreal( arrayAngles ) && length( arrayAngles ) == 3 );
roll = arrayAngles(1);
pitch = arrayAngles(2);
yaw = arrayAngles(3);

dx = lx / (Nx-1);
dy = ly / (Ny-1);

xi = dx * ( 0 : Nx-1 ) - lx/2;
yj = dy * ( 0 : Ny-1 ) - ly/2;

[X, Y, Z] = ndgrid( xi, yj, 0 );

rotationMatrix = angle2dcm( -yaw, -pitch, -roll );

xyzRot = rotationMatrix * [ ToRow( X ); ToRow( Y ); ToRow( Z ) ];

Xtranslated = xyzRot(1, :) + arrayPosition(1);
Ytranslated = xyzRot(2, :) + arrayPosition(2);
Ztranslated = xyzRot(3, :) + arrayPosition(3);

posReceiver = reshape( [Xtranslated ; Ytranslated ; Ztranslated], [3 Nx Ny] );

end
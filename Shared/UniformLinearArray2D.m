function posReceiver = UniformLinearArray2D( arrayDimensions, totalReceivers, arrayPosition, arrayAngles )

lx = arrayDimensions(1);
ly = arrayDimensions(2);
Nx = totalReceivers(1);
Ny = totalReceivers(2);
theta = arrayAngles(1);
phi = arrayAngles(2);

dx = lx / (Nx-1);
dy = ly / (Ny-1);

xi = dx * ( 0 : Nx-1 ) - lx/2;
yj = dy * ( 0 : Ny-1 ) - ly/2;

[X, Y, Z] = meshgrid( xi, yj, 0 );

rotationMatrix = RotationMatrixAzEl( theta, phi );

xyzRot = rotationMatrix * [ ToRow( X ); ToRow( Y ); ToRow( Z ) ];

Xtranslated = xyzRot(1, :) + arrayPosition(1);
Ytranslated = xyzRot(2, :) + arrayPosition(2);
Ztranslated = xyzRot(3, :) + arrayPosition(3);

posReceiver = reshape( [Xtranslated ; Ytranslated ; Ztranslated], [3 Nx Ny] );

end
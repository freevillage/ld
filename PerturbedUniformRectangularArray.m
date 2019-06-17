function posReceiver = PerturbedUniformRectangularArray( arrayDimensions, totalReceivers, arrayPosition, arrayAngles, iPerturbed, jPerturbed, xFractionPerturbed, yFractionPerturbed )

lx = arrayDimensions(1);
ly = arrayDimensions(2);
Nx = totalReceivers(1);
Ny = totalReceivers(2);

if isvector( arrayAngles )
    if length( arrayAngles ) == 2
        theta = arrayAngles(1);
        phi = arrayAngles(2);
        rotationMatrix = RotationMatrixAzEl( theta, phi );
    elseif length( arrayAngles ) == 3
        rotationMatrix = RotationMatrix( arrayAngles(1), arrayAngles(2), arrayAngles(3) );
    end
elseif ismatrix( arrayAngles ) && isequal( size( arrayAngles ), [3 3] )
    rotationMatrix = arrayAngles;
else
    error( 'Rotation info is in invalid format' );
end


dx = lx / (Nx-1);
dy = ly / (Ny-1);

xi = dx * ( 0 : Nx-1 ) - lx/2;
yj = dy * ( 0 : Ny-1 ) - ly/2;

[X, Y, Z] = meshgrid( xi, yj, 0 );

totalPerturbations = length( iPerturbed );

for kPerturbation = 1 : totalPerturbations
    ip = iPerturbed(kPerturbation);
    jp = jPerturbed(kPerturbation);
    dxp = xFractionPerturbed(kPerturbation) * dx;
    dyp = yFractionPerturbed(kPerturbation) * dy;
    
    if ip >= 1 && ip <= Nx && jp >= 1 && jp <= Ny
        X(ip,jp) = X(ip,jp) + dxp;
        Y(ip,jp) = Y(ip,jp) + dyp;
    end
end

xyzRot = rotationMatrix * [ ToRow( X ); ToRow( Y ); ToRow( Z ) ];

Xtranslated = xyzRot(1, :) + arrayPosition(1);
Ytranslated = xyzRot(2, :) + arrayPosition(2);
Ztranslated = xyzRot(3, :) + arrayPosition(3);

posReceiver = reshape( [Xtranslated ; Ytranslated ; Ztranslated], [3 Nx Ny] );


end
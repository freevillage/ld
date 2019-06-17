function rotationMatrix = RotationMatrixAzEl( azimuth, elevation )

horizontalRotationMatrix = RotationMatrix3D( [0; 0; 1], azimuth );
rotatedAxisY = horizontalRotationMatrix * [0; -1; 0];
verticalRotationMatrix = RotationMatrix3D( rotatedAxisY, elevation );

rotationMatrix = verticalRotationMatrix * horizontalRotationMatrix;


end
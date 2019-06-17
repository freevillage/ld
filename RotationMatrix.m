function rotationMatrix = RotationMatrix( alpha, beta, gamma )

rotationMatrix = RotationMatrix3D( [0 0 1], gamma ) ...
    * RotationMatrix3D( [0 1 0], beta ) ...
    * RotationMatrix3D( [1 0 0], alpha );

end % of function
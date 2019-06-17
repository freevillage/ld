function alphabetagamma = RotationAngles( rotationMatrix )

alphabetagamma = fliplr( rotm2eul( rotationMatrix ) );

end
function v = VelocityFromDoppletShift( fReference, fShifted )

warning( 'Will become obsolete. Replace with VelocityFromDopplerShift (note the R)' );

v = LightSpeed * RelativeError(fReference, fShifted);

end
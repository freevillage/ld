function v = VelocityFromDopplerShift( fReference, fShifted )

 v = LightSpeed * RelativeError(fReference, fShifted);

end
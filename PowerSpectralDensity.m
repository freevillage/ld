function psd = PowerSpectralDensity( signal, timeStep )

psd = abs( fft( signal ) ) .^2 / length( signal ) * timeStep; 

end
function directionalPower = MusicDirectionOfArrival( directions, arrayData, arraySpacing, totalSourceComponents, wavelength )

assert( ismatrix( arrayData ) );
totalReceivers = size( arrayData, 1 );

[eigenVecs,~] = eig( CrossCovarianceMatrix( arrayData ) ); 
noiseSpace = eigenVecs( :, 1:totalReceivers-totalSourceComponents );
directionalPower = NormalizeVector( 1 ./ VarianceMatrix( exp( ( -2*pi*1i*arraySpacing/wavelength ) * ToColumn( sin(directions) ) * (0:totalReceivers-1) ) * noiseSpace ) )  ;

end
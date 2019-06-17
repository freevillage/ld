function noise = ComplexGaussianNoise( sigmaNoise, sizeNoise )

assert( IsNumericVector( sigmaNoise ) && ...
    numel( sigmaNoise ) >= 1 && numel( sigmaNoise )  <= 2 );

if numel( sigmaNoise ) == 2
    sigmaNoiseRe = sigmaNoise(1);
    sigmaNoiseIm = sigmaNoise(2);
elseif numel( sigmaNoise ) == 1
    sigmaNoiseRe = sigmaNoise;
    sigmaNoiseIm = sigmaNoise;
else
    error( 'sigmaNoise must have one or two scalars' );
end

noise = sigmaNoiseRe * randn( sizeNoise ) ...
      + 1i * sigmaNoiseIm * randn( sizeNoise );

end
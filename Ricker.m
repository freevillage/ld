function Signal = Ricker( Times, Frequency, InitialTime )

StandardDeviation = RickerStandardDeviation( Frequency );

NormalizedShiftedTimesSquared = ( ( Times - InitialTime ) / StandardDeviation ) .^ 2;
AmplitudeNormalization = 1 / sqrt( 2 * pi * ( StandardDeviation ^ 3 ) );

Signal = AmplitudeNormalization * ( 1 - NormalizedShiftedTimesSquared ) ...
      .* exp( - ( NormalizedShiftedTimesSquared ) / 2.0 );

end

function Std = RickerStandardDeviation( Frequency )

Std = 1 / ( sqrt( 2 ) * pi ) / Frequency;

end
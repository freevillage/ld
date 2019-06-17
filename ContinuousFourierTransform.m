function FrequencySignal = ContinuousFourierTransform( TimeAxis, TimeSignal, FrequencyAxis )

Frequencies = FrequencyAxis.Locations;

Cosines = cos( transpose( Frequencies ) * ones( 1, TimeAxis.NumLocations ) );
Sines = sin( transpose( Frequencies ) * ones( 1, TimeAxis.NumLocations ) );

RealPart = TimeAxis.Step * sum( ones( FrequencyAxis.NumLocations, 1 ) * TimeSignal .* Cosines, 2 );
ImaginaryPart = TimeAxis.Step * sum( ones( FrequencyAxis.NumLocations, 1 ) * TimeSignal .* Sines, 2 );

FrequencySignal = complex( RealPart, ImaginaryPart );


end
function directions = DirectionOfArrival( arrayData, sourceFrequency, arraySpacing, varargin )

phases = DiscreteFrequencySpectrum( arrayData, varargin{:} );

directions = asin( LightSpeed * phases / ( 2*sourceFrequency*arraySpacing ) );

end % of function
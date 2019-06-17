function freqHertz = DiscreteFrequencySpectrumHertz( signal, freqSampling, varargin )

phases = DiscreteFrequencySpectrum( signal, varargin{:} );
freqHertz = phases * freqSampling / 2;

end % of function
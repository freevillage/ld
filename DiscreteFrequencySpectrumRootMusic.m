function phases = DiscreteFrequencySpectrumRootMusic( arrayData, totalPhases )

phases = rootmusic( arrayData', totalPhases ) / pi;

end % of function


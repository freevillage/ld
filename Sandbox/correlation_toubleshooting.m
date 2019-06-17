iMethod = 1 ;
thisMethod = methodDescriptions{iMethod};
thisMethodName = thisMethod{2};
methodNames{iMethod} = thisMethodName;


kSlow = 1;
fastTimeGather = FastTimeGather( recordedData, kSlow );
trace = squeeze( fastTimeGather( 1, 1, : ) );

DiscreteFrequencySpectrumHertz( trace(1:31), ...
    fastSamplingFrequency, ...
    'TotalFrequencies', totalSources, ...
    thisMethod{:} ) - freqSource


iMethod = 2 ;
thisMethod = methodDescriptions{iMethod};
thisMethodName = thisMethod{2};
methodNames{iMethod} = thisMethodName;


kSlow = 1;
fastTimeGather = FastTimeGather( recordedData, kSlow );
trace = squeeze( fastTimeGather( 1, 1, : ) );

DiscreteFrequencySpectrumHertz( trace, ...
    fastSamplingFrequency, ...
    'TotalFrequencies', totalSources, ...
    thisMethod{:} ) - freqSource

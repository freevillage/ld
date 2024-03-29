methodDescriptions = { ...
    { 'Method', 'CorrelationSinglePhase' }, ...
    { 'Method', 'Prony' }, ...
    { 'Method', 'TotalLeastSquaresProny' }, ...
    { 'Method', 'MatrixPencil' }, ...
    { 'Method', 'RootMusic' }, ...
    { 'Method', 'Music', 'FrequencySensitivity', 1e-4, 'TotalRefinements', 3, 'RefinementFactor', 100 }, ...
    { 'Method', 'Esprit' } 
    };


iMethod = 1 ;
thisMethod = methodDescriptions{iMethod};
thisMethodName = thisMethod{2};
methodNames{iMethod} = thisMethodName;


kSlow = 1;
fastTimeGather = FastTimeGather( recordedData, kSlow );
trace = squeeze( fastTimeGather( 11, 1, : ) );

DiscreteFrequencySpectrumHertz( trace(1:31), ...
    fastSamplingFrequency, ...
    'TotalFrequencies', totalSources, ...
    thisMethod{:} ) - freqSource


iMethod = 6 ;
thisMethod = methodDescriptions{iMethod};
thisMethodName = thisMethod{2};
methodNames{iMethod} = thisMethodName;


kSlow = 1;
fastTimeGather = FastTimeGather( recordedData, kSlow );
trace = squeeze( fastTimeGather( 11, 1, : ) );

DiscreteFrequencySpectrumHertz( trace, ...
    fastSamplingFrequency, ...
    'TotalFrequencies', totalSources, ...
    thisMethod{:} ) - freqSource

function DeconvolvedGather = DeconvolveRicker2D( InputGather, CentralFrequency, Stabilization )

assert( ndims( InputTrace ) == 2, ...
    'Dataset:DeconvolveRicker2D:WrongDim', ...
    'The input trace must be a 2D dataset' );

TotalTraces = size( InputGather, 1 );

DeconvolvedGather = InputGather;

for TraceNumber = 1 : TotalTraces
    Trace = squeeze( InputGather( TraceNumber, : ) );
    DeconvolvedTrace = DeconvolveRicker1D( Trace, CentralFrequency, Stabilization );
    DeconvolvedGather.Values( Tracenumber, : ) = DeconvolvedTrace.Values( : );
end


end % of DeconvolveRicker2D
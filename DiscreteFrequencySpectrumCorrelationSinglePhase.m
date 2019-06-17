function phase = DiscreteFrequencySpectrumCorrelationSinglePhase( arrayData )

if isvector( arrayData )
    arrayData = ToColumn( arrayData );
end

totalSnapshots = size( arrayData, 2 );
phase = nan( totalSnapshots, 1 );

for iSnapshot = 1 : totalSnapshots
    phase(iSnapshot) = DFSCorrelationSinglePhaseSingleSnapshot( arrayData(:,iSnapshot) );
end

if totalSnapshots > 1, phase = mean( phase ); end % average over snapshots

end % of function
function phase = DiscreteFrequencySpectrumLeastSquaresSinglePhase( arrayData )

if isvector( arrayData )
    arrayData = ToColumn( arrayData );
end

totalSnapshots = size( arrayData, 2 );
phase = nan( totalSnapshots, 1 );

for iSnapshot = 1 : totalSnapshots
    amplitudePhase = DFSLeastSquaresSingleSnapshot( arrayData(:,iSnapshot) );
    phase(iSnapshot) = amplitudePhase(2);
end

if totalSnapshots > 1, phase = mean( phase ); end % average over snapshots

end % of function
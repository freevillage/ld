function phases = DiscreteFrequencySpectrumTLSProny( arrayData, totalPhases )

if isvector( arrayData )
    arrayData = ToColumn( arrayData );
end

totalSnapshots = size( arrayData, 2 );
phases = nan( totalSnapshots, totalPhases );

for iSnapshot = 1 : totalSnapshots
    phases(iSnapshot,:) = DiscreteFrequencySpectrumTLSPronySingleSnapshot( ...
        arrayData(:,iSnapshot), ...
        totalPhases );
end

if totalSnapshots > 1
    phases = mean( phases ); % average over snapshots
end

end % of function
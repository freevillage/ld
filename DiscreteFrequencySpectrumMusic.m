function phases = DiscreteFrequencySpectrumMusic( arrayData, totalPhases, frequencySensitivity, totalRefinements, refinementFactor )

if isvector( arrayData )
    arrayData = ToColumn( arrayData );
end

totalSnapshots = size( arrayData, 2 );
phases = nan( totalSnapshots, totalPhases );

for iSnapshot = 1 : totalSnapshots
    phases(iSnapshot,:) = DiscreteFrequencySpectrumMusicSingleSnapshot( ...
        arrayData(:,iSnapshot), ...
        totalPhases, ...
        frequencySensitivity, ...
        totalRefinements, ...
        refinementFactor );
end

if totalSnapshots > 1
    phases = mean( phases ); % average over snapshots
end

end % of function
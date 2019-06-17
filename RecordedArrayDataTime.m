function recordings = RecordedArrayDataTime( fastTime, receiverPosition, GetSourcePosition, sourceAmplitude, sourceFreq, sourcePhase )

c = physconst('LightSpeed');


[totalSlowTimes, totalFastTimes, totalDims, totalAntennasX, totalAntennasY] ...
    = size( receiverPosition );
assert( isequal( [totalSlowTimes totalFastTimes], size( fastTime ) ) );

totalTimes = totalSlowTimes * totalFastTimes;
totalAntennas = totalAntennasX * totalAntennasY;

totalSources = length( GetSourcePosition );

xr = reshape( permute( receiverPosition, [3 1 2 4 5] ), ...
    [ totalDims totalTimes totalAntennas ] );
t = ToRow( fastTime );

Distance = @(x,y) squeeze( sqrt( sum( (x-y).^2 ) ) );

recordings = zeros( totalTimes, totalAntennas );

for is = 1 : totalSources
    xs = repmat( cell2mat( arrayfun( GetSourcePosition{is}, t, ...
        'UniformOutput', false ) ), ...
        [1 1 totalAntennas] );
    distances = Distance( xs, xr );
    
    recordings = recordings + ...
        sourceAmplitude(is) ./ (4*pi * distances)  .* ...
        exp( -2*pi*1i*sourceFreq(is) / c  ...
        .* ( distances - repmat( c*ToColumn(t), [1 totalAntennas] ) ) ...
        + c*sourcePhase(is) );
end


recordings = reshape( ...
    recordings, ...
    [totalSlowTimes totalFastTimes totalAntennasX totalAntennasY] );


end

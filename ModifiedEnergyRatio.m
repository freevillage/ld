function signalMer = ModifiedEnergyRatio( signal, windowHalfLength, waterLevel )

signal = ToRow( signal );

windowLength = 2 * windowHalfLength - 1;
slidingWindowSize = [1 windowLength];

signalMer = nlfilter( signal, ...
    slidingWindowSize, ...
    @(s) WindowModifiedEnergyRatio( s, waterLevel ) );

end

function modifiedEnergyRatio = WindowModifiedEnergyRatio( windowedSignal, waterLevel )

totalPoints = length( windowedSignal );
assert( IsOdd( totalPoints ) );

middlePoint = (totalPoints+1) / 2;
signalFirstHalf  = windowedSignal( 1 : middlePoint );
signalSecondHalf = windowedSignal( middlePoint : end );

energySquaredFirst  = sum( signalFirstHalf  .^ 2 );
energySquaredSecond = sum( signalSecondHalf .^ 2 );
energyRatio = energySquaredSecond / ( energySquaredFirst + waterLevel );

modifiedEnergyRatio = (energyRatio * abs( windowedSignal(middlePoint)) ) ^ 3;

end




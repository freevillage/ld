signal =  squeeze( recordedDataCoarse{iSource}(1,1,1:1001,1) );
time = fastTimeLong(1:1001,1);

signal = ToRow( signal(1:end) );
time = ToRow( time(1:end) );

subplot( 3, 1, 1 ), plot( 10^6 * time, real(signal) )
title( 'Original signal' )
xlim( minmax( 1e6 * time ) )
xlabel( 'Time [\mus]' )

DemodulateReal = @(signal,time,freqCarrier,downsampleRatio) decimate( real( signal .* exp( 2*pi*1i* freqCarrier * time ) ), downsampleRatio );
Demodulate =  @(signal,time,freqCarrier,downsampleRatio) ...
    DemodulateReal(real(signal),time,freqCarrier,downsampleRatio) + 1i* DemodulateReal(imag(signal),time,freqCarrier,downsampleRatio);

signalShifted = signal .* exp( 2*pi*1i* freqCarrier * time );

subplot( 3, 1, 2 ), plot( 10^6 * time, real( signalShifted ) ) 
xlim( minmax( 1e6 * time ) )
xlabel( 'Time [\mus]' )
title( 'Demodulated signal' )

downsampleRatio = fastSamplingFrequency / downsampledFrequency;

signalDownsampled = decimate( real(signalShifted), downsampleRatio );
timeDownsampled = decimate( real(time), downsampleRatio );

subplot( 3, 1, 3 )

signalDemodulated = Demodulate(signal,time,freqCarrier,downsampleRatio);

plot( ...
    10^6 * timeDownsampled, real(signalDemodulated), ...
    10^6 * timeDownsampled, imag(signalDemodulated) ...
    )
legend( 'Re', 'Im' )
xlim( minmax( 1e6 * time ) )
title( 'Downsampled signal' )
xlabel( 'Time [\mus]' )
suptitle( 'Demodulation test' )


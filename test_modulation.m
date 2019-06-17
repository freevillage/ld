timeInitial = 0;
timeFinal = 0.0001;
freqSampling = 2e7; % Hz;
freqSignal = 2e6; % Hz
time = timeInitial : 1/freqSampling : timeFinal;
signal = exp( 2*pi*1i * freqSignal * time );

freqCarrier = 1e8; % Hz
freqResampling = 1e9; % Hz

assert( freqResampling > 2*(freqCarrier + freqSignal) );

[signalResampled, timeResampled] = resample( signal, time, freqResampling ); 

% ModulateSignal = @(signal) modulate( signal, ...
%     freqCarrier, ...
%     freqResampling, ...
%     'qam', ...
%     zeros( size( signal ) ) ...
%     );

ModulateSignal = @(signal) ...
    signal .* exp( 2*pi*1i * freqCarrier * timeResampled );

% DemodulateSignal = @(signal) demod( signal, ...
%     freqCarrier, ...
%     freqResampling, ...
%     'qam' ...
%     );

DemodulateSignal = @(signal) ...
    signal .* exp( -2*pi*1i * freqCarrier * timeResampled );
    

signalModulated = ModulateSignal( signalResampled );
snr = 10; % dB
signalModulatedNoisy = awgn( signalModulated, snr, 'measured' );

signalDemodulated = DemodulateSignal( signalModulatedNoisy );
% signalDownsampled = interp1( timeResampled, signalDemodulated, time );

signalDownsampled = decimate( signalDemodulated, freqResampling/freqSampling );

plot( ...
    time, real( signal ), ...
    time, real( signalDownsampled ), ...
    'LineWidth', 2 ...
    );
legend( 'Original', 'Mod+Awgn+Demod' );
xlabel( 'Time (s)' );
ylabel( 'Real part' );
xlim( minmax( time ) );


%%
clc
DiscreteFrequencySpectrumHertz( signal, freqSampling, 'Method', 'CorrelationSinglePhase' )
DiscreteFrequencySpectrumHertz( signalResampled, freqResampling, 'Method', 'CorrelationSinglePhase' )
DiscreteFrequencySpectrumHertz( signalModulated, freqResampling, 'Method', 'CorrelationSinglePhase' )
DiscreteFrequencySpectrumHertz( signalDemodulated, freqResampling, 'Method', 'CorrelationSinglePhase' )
DiscreteFrequencySpectrumHertz( signalDownsampled, freqSampling, 'Method', 'CorrelationSinglePhase' )
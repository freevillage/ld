

clear all;

fc = 300e6;
fs = 1200e6;    % original sampling rate

W = 10e6;       % how much bandwidth to maintain at downsampling
R = 5e6;        % pulsing rate (to create example modulation signal)

fs2 = 4*W;      % target output sampling rate
DS = fs/fs2;    % how much to downsample

% %% design a Chebyshev type II filter
% Rs = 80;  Wn = W/fs;
% [b,a] = cheby2(10, Rs, Wn, 'low');

%% make an example bandlimited signal
bb_overSample = fs/R;
bb_pulse = rcosfir(0.8, [5 5], bb_overSample);
bb_Npulses = 15;
bb_amplitudes = randn(bb_Npulses,1) + 1i*randn(bb_Npulses,1);
bb_signal = upfirdn(bb_amplitudes, bb_pulse, bb_overSample, 1);

%% modulate to fc
pb_signal = real(bb_signal.*exp(1i*fc*(0:length(bb_signal)-1).'/fs) );

%% demodulate back to 0 Hz
zz_sigShifted = 2*pb_signal.*exp(-1i*fc*(0:length(bb_signal)-1).'/fs);
zz_signal = decimate(zz_sigShifted, DS);

%% compare
figure(1);
subplot(411);
plot( (0:length(bb_signal)-1).'/fs, [real(bb_signal)], 'o' );
title('real value of original'); xlabel('time [s]');
subplot(412);
plot( (0:length(zz_signal)-1).'/fs, [real(zz_signal)], 'x' );
title('real value of downsampled'); xlabel('time [s]');
subplot(413);
plot( (0:length(bb_signal)-1).'/fs, [imag(bb_signal)], 'ro' );
title('imag value of original'); xlabel('time [s]');
subplot(414);
plot( (0:length(zz_signal)-1).'/fs, [imag(zz_signal)], 'rx' );
title('imag value of downsampled'); xlabel('time [s]');



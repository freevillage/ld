function demodulatedSignal = DemodulateSignal( signal, time, freqCarrier, downsampleRatio )

% DemodulateReal = @(signal,time,freqCarrier,downsampleRatio) ...
%     downsample( real( signal .* exp( 2*pi*1i* freqCarrier * time ) ), downsampleRatio );
% demodulatedSignal = DemodulateReal(real(signal),time,freqCarrier,downsampleRatio) ...
%     + 1i* DemodulateReal(imag(signal),time,freqCarrier,downsampleRatio);

demodulatedSignal = decimate( signal .* exp( -2*pi*1i * freqCarrier * time ), downsampleRatio );

% product = signal .* exp( 2*pi*1i * freqCarrier * time );
% 
% realPart = decimate( real( product ), downsampleRatio );
% 
% if isreal( signal )
%     demodulatedSignal = realPart;
% else
%     imagPart = decimate( imag( product ), downsampleRatio );
%     demodulatedSignal = realPart + 1i * imagPart;
% end

end
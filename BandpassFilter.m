function signalFiltered = BandpassFilter( signal, freqStop1, freqPass1, freqPass2, freqStop2, rippleStop1, ripplePass, rippleStop2 )

% The function is now implemented only for one-dimensional signals. The
% independent variable is assumed to be time.
switch( ndims( signal ) )
    case 1
        freqSampling = 1 / signal.Axes.Step;
        
        filterSpecs = fdesign.bandpass( 'Fst1,Fp1,Fp2,Fst2,Ast1,Ap,Ast2', ...
            freqStop1, freqPass1, freqPass2, freqStop2, rippleStop1, ripplePass, rippleStop2, freqSampling );
        
        filterBandpass = design( filterSpecs, 'equiripple', 'MinOrder', 'any' );
        
        signalValuesFiltered = filtfilt( filterBandpass.Numerator, 1, signal.Values );
        
        
        signalFiltered.Values = signalValuesFiltered;
        
    case 2
        TotalTraces = size( signal, 1 );
        signalFiltered = signal;
        for TraceNumber = 1 : TotalTraces
            Trace = squeeze( signal( TraceNumber, : ) );
            FilteredTrace = BandpassFilter( Trace, filterOrder, Fpass1, Fpass2, Fstop1, Fstop2 );
            signalFiltered.Values( TraceNumber, : ) = FilteredTrace.Values;
        end
        
    otherwise
        error( 'Signal dimension must be 1 or 2' );
end

end
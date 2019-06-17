totalPeriods = 20;
totalSigmas = 7;
totalMethods = 4;
saveDirectory = '/scratch/poliann/mat';

numberPeriods = round( logspace( 0, 4, totalPeriods ) );
sigmasNoise = logspace( -12, -6, totalSigmas );
% coeffs = logspace( 0, 5, 6 );


for jSnr = 1 : totalSigmas
    for iPeriod = 1 : totalPeriods
        test_doa_resolution_fasttime( numberPeriods(iPeriod), 1, sigmasNoise(jSnr) )
    end
%     plot_doa_resolution_results
    
end

%%

angleEstimationErrorNorm = nan( 2, totalSigmas, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );


for jSnr = 1 : totalSigmas
    for iPeriod = 1 : totalPeriods
        filename = fullfile( saveDirectory, sprintf( 'test_doa_results_%.0f_%.0f.mat', numberPeriods(iPeriod),  log10( sigmasNoise(jSnr) ) ) );
        savedResults = load( filename );
        for kMethod = 1 : totalMethods
            methodNames{kMethod} = savedResults.methodDescriptions{kMethod}{2};
            anglesTrue = savedResults.anglesTrue(:,:,1);
            anglesEstimated = savedResults.anglesEstimated(:,:,kMethod);
            
            angleEstimationErrorNorm(:,jSnr,iPeriod,kMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
        end
    end
end



%%

numberPeriodsOptimal = nan( totalSigmas, 1 );

for iSnr = 1 : totalSigmas
    [numberPeriodsOptimal(iSnr),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,iSnr,:,1) ) );
end

 figure( 'Visible', 'Off' )
 loglog( sigmasNoise, numberPeriodsOptimal, '-o' )
 xlabel( 'SNR' )
 ylabel( 'Fast time recording window [periods]' )
 title( 'Optimal fast time window' )
 grid on
 orient landscape, 
 print -dpdf html/optimal_tau_snr
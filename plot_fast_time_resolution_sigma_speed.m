% Altitude
initialAltitude = 300;
% initialAltitude = linspace( 30, 30000, 10 );
totalAltitudes = length( initialAltitude );

% Clock shift
clockShift = 0;
% clockShift = linspace( -30e6, 30e6, 10 );
totalClockShifts = length( clockShift );

% Aspect angle
aspectAngles = pi/2;
% aspectAngles = linspace( 0, pi/2, 5 );
totalAspectAngles = length( aspectAngles );

% Sigma Noise
% sigmaNoise = 1e-11;
sigmaNoise = logspace( -15, -8, 8 );
totalSigmas = length( sigmaNoise );

% Fast time windows
totalPeriods = 40;
numberPeriods = round( logspace( 0, 4, totalPeriods ) );
totalMethods = 1;
saveDirectory = '/scratch/poliann/mat_all_new';

% Array speeds (conflicts with aspect angle)
arraySpeed = [ 0, 40, 400, 4000, 40000, 400000 ];
totalSpeeds = length( arraySpeed );

parfor iPeriod = 1 : totalPeriods
    for jAltitude = 1 : totalAltitudes
        for kClock = 1 : totalClockShifts
            for lAngle = 1 : totalAspectAngles
                for mSigma = 1 : totalSigmas
                    for nSpeed = 1 : totalSpeeds
                        test_doa_methods_all( numberPeriods(iPeriod), initialAltitude(jAltitude), clockShift(kClock), aspectAngles(lAngle), sigmaNoise(mSigma), arraySpeed(nSpeed) )
                    end
                end
            end
        end
    end   
end

%%

angleEstimationErrorNorm = nan( 2, totalSigmas, totalPeriods, totalSpeeds, totalMethods );
methodNames = cell( totalMethods, 1 );


for mSigma = 1 : totalSigmas
    for iPeriod = 1 : totalPeriods
        for nSpeed = 1 : totalSpeeds
            filename = fullfile( saveDirectory, sprintf( 'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f.mat', ...
                numberPeriods(iPeriod), initialAltitude, clockShift, aspectAngles, log10(sigmaNoise(mSigma)), arraySpeed(nSpeed) ) );
            savedResults = load( filename );
            for oMethod = 1 : totalMethods
                methodNames{oMethod} = savedResults.methodDescriptions{oMethod}{2};
                anglesTrue = savedResults.anglesTrue(:,:,1);
                anglesEstimated = savedResults.anglesEstimated(:,:,oMethod);
                
                angleEstimationErrorNorm(:,mSigma,iPeriod,nSpeed,oMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
            end
        end
    end
end



%%

numberPeriodsOptimal = nan( totalSigmas, 2 );

for mSigma = 1 : totalSigmas
    [numberPeriodsOptimal(mSigma,1),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,mSigma,:,1) ) );
    [numberPeriodsOptimal(mSigma,2),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,mSigma,:,1) ) );
end

figure( 'Visible', 'On' )
plotError = loglog( numberPeriods, squeeze( angleEstimationErrorNorm(1,:,:,1) ), ...
    '-o', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%xlim( [0 4000] )
xlabel( 'Fast time recording window [periods]' )
ylabel( 'Angle estimation RMS error' )
title( 'Angle estimation error as function of sigma noise' )
orient landscape
sigmaNoiseLabels = arrayfun( @num2str, sigmaNoise, 'UniformOutput', false );
legend( sigmaNoiseLabels{:}, 'Location', 'NorthWest' )
set( plotError(end-1), 'LineWidth', 5 )
grid on
print -dpdf html/error_tau_sigma_noise

 figure( 'Visible', 'On' )
 plot( sigmaNoise, numberPeriodsOptimal(:,1), '-o', 'LineWidth', 2 )
  xlabel( 'Sigma noise amplitude' )
 ylabel( 'Fast time recording window [periods]' )
 title( 'Optimal fast time window' )
 grid on
 orient landscape, 
 print -dpdf html/optimal_tau_sigma_noise
 save( fullfile( saveDirectory, 'plot_sigma_noise.mat' ), '-v7.3' )
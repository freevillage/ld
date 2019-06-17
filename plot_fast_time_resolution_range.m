% Altitude
% initialAltitude = 3000;
initialAltitude = linspace( 1000, 5000, 9 );
totalAltitudes = length( initialAltitude );

% Clock shift
clockShift = 0;
% clockShift = linspace( -30e6, 30e6, 10 );
totalClockShifts = length( clockShift );

% Aspect angle
aspectAngle = pi/2;
% aspectAngles = linspace( 0, pi/2, 5 );
totalAspectAngles = length( aspectAngle );

% Sigma Noise
sigmaNoise = 1e-12;
% sigmaNoise = logspace( -13, -8, 6 );
totalSigmas = length( sigmaNoise );

% Fast time windows
totalPeriods = 9;
numberPeriods = round( logspace( 2, 4, totalPeriods ) );
totalMethods = 1;
saveDirectory = '/scratch/poliann/mat_all';

parfor iPeriod = 1 : totalPeriods
    for jAltitude = 1 : totalAltitudes
        for kClock = 1 : totalClockShifts
            for lAngle = 1 : totalAspectAngles
                for mSigma = 1 : totalSigmas
                    test_doa_methods_all_parameters( numberPeriods(iPeriod), initialAltitude(jAltitude), clockShift(kClock), aspectAngle(lAngle), sigmaNoise(mSigma) )
                end
            end
        end
    end   
end

%%

angleEstimationErrorNorm = nan( 2, totalAltitudes, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );


for jAltitude = 1 : totalAltitudes
    for iPeriod = 1 : totalPeriods
        filename = fullfile( saveDirectory, sprintf( 'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f.mat', ...
            numberPeriods(iPeriod), initialAltitude(jAltitude), clockShift, aspectAngle, log10(sigmaNoise) ) );
        savedResults = load( filename );
        for kMethod = 1 : totalMethods
            methodNames{kMethod} = savedResults.methodDescriptions{kMethod}{2};
            anglesTrue = savedResults.anglesTrue(:,:,1);
            anglesEstimated = savedResults.anglesEstimated(:,:,kMethod);
            
            angleEstimationErrorNorm(:,jAltitude,iPeriod,kMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
        end
    end
end



%%

numberPeriodsOptimal = nan( totalAltitudes, 2 );

for jAltitude = 1 : totalAltitudes
    [numberPeriodsOptimal(jAltitude,1),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,jAltitude,:,1) ) );
    [numberPeriodsOptimal(jAltitude,2),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,jAltitude,:,1) ) );
end

figure( 'Visible', 'On' );
loglog( numberPeriods, squeeze( angleEstimationErrorNorm(1,:,:,1) ), ...
    '-o', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' )
 print -dpdf html/error_tau_altitude


 figure( 'Visible', 'On' )
 loglog( initialAltitude, numberPeriodsOptimal(:,1), '-o', 'LineWidth', 2 )
 xlabel( 'Initial altitude [m]' )
 ylabel( 'Fast time recording window [periods]' )
 title( 'Optimal fast time window' )
 grid on
 orient landscape, 
 print -dpdf html/optimal_tau_altitude
 save( fullfile( saveDirectory, 'plot_altitude.mat' ), '-v7.3' )
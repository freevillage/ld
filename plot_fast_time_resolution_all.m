% Altitude
initialAltitude = 3000;
% initialAltitude = linspace( 30, 30000, 10 );
totalAltitudes = length( initialAltitude );

% Clock shift
clockShift = 0;
% clockShift = linspace( -30e6, 30e6, 10 );
totalClockShifts = length( clockShift );

% Aspect angle
aspectAngles = 0;
% aspectAngles = linspace( 0, pi/2, 5 );
totalAspectAngles = length( aspectAngles );

% Sigma Noise
sigmaNoise = 1e-11;
% sigmaNoise = logspace( -13, -8, 6 );
totalSigmas = length( sigmaNoise );

% Fast time windows
totalPeriods = 8;
numberPeriods = round( logspace( 2, 4, totalPeriods ) );
totalMethods = 1;
saveDirectory = '/scratch/poliann/mat_all';

for iPeriod = 1 : totalPeriods
    for jAltitude = 1 : totalAltitudes
        for kClock = 1 : totalClockShifts
            for lAngle = 1 : totalAspectAngles
                for mSigma = 1 : totalSigmas
                    test_doa_methods_all_parameters( numberPeriods(iPeriod), initialAltitude(jAltitude), clockShift(kClock), aspectAngles(lAngle), sigmaNoise(mSigma) )
                end
            end
        end
    end   
end

%%

angleEstimationErrorNorm = nan( 2, totalAspectAngles, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );


for lAngle = 1 : totalAspectAngles
    for iPeriod = 1 : totalPeriods
        filename = fullfile( saveDirectory, sprintf( 'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f.mat', ...
            numberPeriods(iPeriod), initialAltitude, clockShift, aspectAngles(lAngle), sigmaNoise ) );
        savedResults = load( filename );
        for kMethod = 1 : totalMethods
            methodNames{kMethod} = savedResults.methodDescriptions{kMethod}{2};
            anglesTrue = savedResults.anglesTrue(:,:,1);
            anglesEstimated = savedResults.anglesEstimated(:,:,kMethod);
            
            angleEstimationErrorNorm(:,lAngle,iPeriod,kMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
        end
    end
end



%%

numberPeriodsOptimal = nan( totalAspectAngles, 2 );

for lAngle = 1 : totalAspectAngles
    [numberPeriodsOptimal(lAngle,1),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,lAngle,:,1) ) );
    [numberPeriodsOptimal(lAngle,2),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,lAngle,:,1) ) );
end

 figure( 'Visible', 'Off' )
 plot( rad2deg(aspectAngles), numberPeriodsOptimal(:,1), '-o', ...
     rad2deg(aspectAngles), numberPeriodsOptimal(end,1) ./ sin(aspectAngles), '-d', ...
     'LineWidth', 2 )
  xlabel( 'Aspect angle [deg]' )
 ylabel( 'Fast time recording window [periods]' )
 title( 'Optimal fast time window' )
 grid on
 legend( '\tau_{optimal}', 'C / sin(\alpha)' )
 orient landscape, 
 print -dpdf html/optimal_tau_angle
 save( fullfile( saveDirectory, 'plot_angle.mat' ), '-v7.3' )
% Altitude
initialAltitude = 3000;
% initialAltitude = linspace( 30, 30000, 10 );
totalAltitudes = length( initialAltitude );

% Clock shift
clockShift = 0;
%clockShift = linspace( -3e4, 3e4, 9 );
totalClockShifts = length( clockShift );

% Aspect angle
aspectAngles = pi/2;
% aspectAngles = linspace( 0, pi/2, 5 );
totalAspectAngles = length( aspectAngles );

% Sigma Noise
sigmaNoise = 1e-12;
% sigmaNoise = logspace( -13, -8, 6 );
totalSigmas = length( sigmaNoise );

% Fast time windows
totalPeriods = 17;
numberPeriods = round( logspace( 2, 4, totalPeriods ) );
totalMethods = 1;
saveDirectory = '/scratch/poliann/mat_all_new';

parfor iPeriod = 1 : totalPeriods
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

angleEstimationErrorNorm = nan( 2, totalClockShifts, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );


for kClock = 1 : totalClockShifts
    for iPeriod = 1 : totalPeriods
        filename = fullfile( saveDirectory, sprintf( 'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f.mat', ...
            numberPeriods(iPeriod), initialAltitude, clockShift(kClock), aspectAngles, log10(sigmaNoise) ) );
        savedResults = load( filename );
        for nMethod = 1 : totalMethods
            methodNames{nMethod} = savedResults.methodDescriptions{nMethod}{2};
            anglesTrue = savedResults.anglesTrue(:,:,1);
            anglesEstimated = savedResults.anglesEstimated(:,:,nMethod);
            
            angleEstimationErrorNorm(:,kClock,iPeriod,nMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
        end
    end
end



%%

numberPeriodsOptimal = nan( totalClockShifts, 2 );

for kClock = 1 : totalClockShifts
    [numberPeriodsOptimal(kClock,1),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,kClock,:,1) ) );
    [numberPeriodsOptimal(kClock,2),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,kClock,:,1) ) );
end

 figure( 'Visible', 'On' )
 plot( clockShift, numberPeriodsOptimal(:,1), '-o', 'LineWidth', 2 )
  xlabel( 'Clock shift [Hz]' )
 ylabel( 'Fast time recording window [periods]' )
 title( 'Optimal fast time window' )
 grid on
 orient landscape, 
 print -dpdf html/optimal_tau_clockshift
 save( fullfile( saveDirectory, 'plot_clockshift.mat' ), '-v7.3' )
 
 
 figure( 'Visible', 'On' )
subplot( 2, 1, 1 )
plotError1 = semilogx( ...
    numberPeriods, squeeze( angleEstimationErrorNorm(1,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError1(clockShift==0), 'LineWidth', 5 )

grid on
xlim( [1e2 1e4] )
xlabel( 'Fast time recording window [periods]' )
ylabel( 'Angle estimation RMS error' )
orient landscape


subplot( 2, 1, 2 )
plotError2 = semilogx( ...
    numberPeriods, squeeze( angleEstimationErrorNorm(2,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
set( plotError2(clockShift==0), 'LineWidth', 5 )

grid on
xlim( [1e2 1e4] )
xlabel( 'Fast time recording window [periods]' )
ylabel( 'Angle estimation RMS error' )
title( 'Angle estimation error as function of clock shift' )
orient landscape


 
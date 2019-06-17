% Plotting preferences
SetDefaultFigureProperties

% Altitude
initialAltitude = 3000;
%initialAltitude = linspace( 30, 30000, 10 );
totalAltitudes = length( initialAltitude );

% Clock shift
% clockShift = 0;
%clockShift = linspace( -1e6, 1e6, 9 );
%clockShift = logspace( 1, 6, 6 ); clockShift = [ fliplr(-clockShift), 0, clockShift ];
clockShift = 0;
% clockShift = [ 0, 0 ];
% clockShift = 15*(0:10);

totalClockShifts = length( clockShift );

% Aspect angle
aspectAngles = pi/2;
% aspectAngles = linspace( 0, pi/2, 5 );
totalAspectAngles = length( aspectAngles );

% Sigma Noise
sigmaNoise = 1e-5;
% sigmaNoise = logspace( -13, -8, 6 );
%sigmaNoise = [ 1e-11, 1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4 ];
totalSigmas = length( sigmaNoise );

% Array perturbations
arrayPerturbations = struct( 'i', 1, 'j', 1, 'dx', 0, 'dy', 0 ); 

% Fast time windows
totalPeriods = 9;
numberPeriods = round( logspace( 1, 5, totalPeriods ) );
%numberPeriods = 10.^(2+0.0395*(0:100));
% numberPeriods = 1000:1000:10000;
totalPeriods = length( numberPeriods );

totalMethods = 1;
saveDirectory = '/wavedata/poliann/mat_all_new';

% Array speed
%arraySpeed = [4 40 400 4000 40000];
arraySpeed = 40;
totalSpeeds = length( arraySpeed );

% Array spin
rollRate = logspace( -2, 3, 6 );
totalRollRates = length( rollRate );

parfor iPeriod = 1 : totalPeriods
    for jAltitude = 1 : totalAltitudes
        for kClock = 1 : totalClockShifts
            for lAngle = 1 : totalAspectAngles
                for mSigma = 1 : totalSigmas
                    for nSpeed = 1 : totalSpeeds
			for oRoll = 1 : totalRollRates
                        test_doa_spin( ...
                            numberPeriods(iPeriod), ...
                            initialAltitude(jAltitude), ...
                            clockShift(kClock), ...
                            aspectAngles(lAngle), ...
                            sigmaNoise(mSigma), ...
                            [arraySpeed(nSpeed), rollRate(oRoll)] ...
                            );
			end
                    end
                end
            end
        end
    end
end

%%

angleEstimationErrorNorm = nan( 2, totalRollRates, totalPeriods, totalMethods );
angleEstimations = nan( 2, totalRollRates, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );


for oRoll = 1 : totalRollRates
    for iPeriod = 1 : totalPeriods
        %if isscalar( arraySpeed ) || arraySpeed(2) == 0
        %    filename = sprintf( ...
        %        'test_spin_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f_%.8f.mat', ...
        %        numberPeriods(iPeriod), initialAltitude, clockShift(kClock), aspectAngles, log10(sigmaNoise), arraySpeed, mean(arrayPerturbations.dx) );
        %else
            filename = sprintf( ...
                'test_spin_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f-%.2f_%.8f.mat', ...
                numberPeriods(iPeriod), initialAltitude, clockShift, aspectAngles, log10(sigmaNoise), arraySpeed, rollRate(oRoll), mean(arrayPerturbations.dx) );
        %end
        filename = fullfile( saveDirectory, filename );
        savedResults = load( filename );
        for nMethod = 1 : totalMethods
            methodNames{nMethod} = savedResults.methodDescriptions{nMethod}{2};
            halfNumberPeriods = round(numberPeriods(iPeriod)/2);
            anglesTrue = savedResults.anglesTrue(:,:,halfNumberPeriods);
            %anglesTrue = savedResults.anglesTrue(:,:,1);
            anglesEstimated = savedResults.anglesEstimated(:,:,nMethod);
            
            % angleEstimationErrorNorm(:,kClock,iPeriod,nMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
            angleEstimationErrorNorm(:,oRoll,iPeriod,nMethod) = abs( anglesEstimated - anglesTrue );
            angleEstimations(:,oRoll,iPeriod,nMethod) = rad2deg(anglesEstimated);
        end
    end
end



%%

numberPeriodsOptimal = nan( totalRollRates, 2 );
errorOptimal = nan( totalRollRates, 2 );

% speedAngleLabel = [ ...
%     '_v_', ...
%     num2str( arraySpeed ), ...
%     '_a_', ...
%     num2str( aspectAngles ), ...
%     '_h_', ...
%     num2str( initialAltitude ) ];

speedAngleSnrLabel = sprintf( ...
    '_v_%.0f_a_%.2f_h_%.0f_s_%.0f',...
    arraySpeed, ...,
    aspectAngles, ...
    initialAltitude, ...
    savedResults.dataSNR );


for oRoll = 1 : totalRollRates
    [numberPeriodsOptimal(oRoll,1),errorOptimal(oRoll,1)] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,oRoll,:,1) ) );
    [numberPeriodsOptimal(oRoll,2),errorOptimal(oRoll,2)] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,oRoll,:,1) ) );
end

fastTimePeriod = 1e-9;

%%%%%%%%%%%%%%%%%%%
figure( 'Visible', 'On' )
%subplot( 2, 1, 1 )
plotError1 = loglog( ...
    numberPeriods*fastTimePeriod, squeeze( angleEstimationErrorNorm(1,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError1(clockShift==0), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
%ylim( [0 7e-7] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Angle estimation error [rad]' )
title( 'Angle estimation error \epsilon_{\theta_x} as function of roll rate' )
orient landscape
clockShiftLabels = arrayfun( @(f) [num2str(f), ' Hz'], rollRate, ...
    'UniformOutput', false );
legend( clockShiftLabels{:}, 'Location', 'EastOutside' )
superLabel = sprintf( ...
    'v=%.0f m/s, alpha=%.2f rad, H=%.0f m, SNR=%.0f dB',...
    arraySpeed, ...,
    aspectAngles, ...
    initialAltitude, ...
    savedResults.dataSNR );
suptitle( superLabel )


figure( 'Visible', 'on' )
%subplot( 2, 1, 2 )
plotError2 = loglog( ...
    fastTimePeriod*numberPeriods, squeeze( angleEstimationErrorNorm(2,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError2(clockShift==0), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Angle estimation error [rad]' )
title( 'Angle estimation error \epsilon_{\theta_y} as function of roll rate' )
orient landscape

legend( clockShiftLabels{:}, 'Location', 'EastOutside' )
superLabel = sprintf( ...
    'v=%.0f m/s, alpha=%.2f rad, H=%.0f m, SNR=%.0f dB',...
    arraySpeed, ...,
    aspectAngles, ...
    initialAltitude, ...
    savedResults.dataSNR );
suptitle( superLabel )
orient landscape
print( ['html/error_tau_rollrate', speedAngleSnrLabel, '.pdf'], '-dpdf' )


%%%%%%%%%%%%%%%%%%%%
figureTotalError = figure( 'Visible', 'On' );
plotTotalError = loglog( ...
    fastTimePeriod*numberPeriods, squeeze( mean( angleEstimationErrorNorm(:,:,:,1) ) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotTotalError(clockShift==0), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Angle estimation error [rad]' )
title( 'Angle estimation error as function of roll rate' )
orient landscape

legend( clockShiftLabels{:}, 'Location', 'EastOutside' )
superLabel = sprintf( ...
    'v=%.0f m/s, alpha=%.2f rad, H=%.0f m, SNR=%.0f dB',...
    arraySpeed, ...,
    aspectAngles, ...
    initialAltitude, ...
    savedResults.dataSNR );
%suptitle( superLabel )
orient landscape
print( figureTotalError, ['html/total_error_tau_rollrate', speedAngleSnrLabel, '.pdf'], '-dpdf' )
%%%%%%%%%%%%%%%%%%
figure( 'Visible', 'On' )
subplot( 2, 1, 1 )
plotError1 = semilogx( ...
    numberPeriods*fastTimePeriod, squeeze( angleEstimations(1,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError1(clockShift==0), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
%ylim( [0 7e-7] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Estimated angle [deg]' )
ylim( [-10 10] )
title( 'Estimated angle \theta_x as function of roll rate' )
orient landscape
clockShiftLabels = arrayfun( @(f) [num2str(f), ' Hz'], rollRate, ...
    'UniformOutput', false );
legend( clockShiftLabels{:}, 'Location', 'EastOutside' )

subplot( 2, 1, 2 )
plotError2 = semilogx( ...
    fastTimePeriod*numberPeriods, squeeze( angleEstimations(2,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
set( plotError2(clockShift==0), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Estimated angle [deg]' )
ylim( [-10 10] )
title( 'Estimated angle \theta_y as function of roll rate' )
orient landscape

legend( clockShiftLabels{:}, 'Location', 'EastOutside' )
superLabel = sprintf( ...
    'v=%.0f m/s, alpha=%.2f rad, H=%.0f m, SNR=%.0f dB',...
    arraySpeed, ...,
    aspectAngles, ...
    initialAltitude, ...
    savedResults.dataSNR );
suptitle( superLabel )
orient landscape
print( ['html/error_tau_rollrate', speedAngleSnrLabel, '.pdf'], '-dpdf' )


 
figure( 'Visible', 'On' )
plot( rollRate, errorOptimal(:,1), '-o', 'LineWidth', 2, 'MarkerFaceColor', 'auto' )
xlabel( 'Roll rate [Hz]' )
ylabel( 'Minimum error [rad]' )
title( 'Minimum angle estimation error' )
suptitle( superLabel )
grid on
orient landscape 
print( ['html/optimal_error_rollrate', speedAngleSnrLabel, '.pdf'], '-dpdf' )

 
 figure( 'Visible', 'On' )
 plot( clockShift, fastTimePeriod * numberPeriodsOptimal(:,1), '-o', 'LineWidth', 2, 'MarkerFaceColor', 'auto' )
 xlabel( 'Roll rate [Hz]' )
 ylabel( 'Fast time recording window [s]' )
 title( 'Optimal fast time window' )
 suptitle( superLabel )
 grid on
 orient landscape, 
 print( ['html/optimal_tau_rollrate', speedAngleSnrLabel, '.pdf'], '-dpdf' )
 save( fullfile( saveDirectory, 'plot_rollrate.mat' ), '-v7.3' )

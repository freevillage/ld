% Altitude
initialAltitude = 300000;
%initialAltitude = linspace( 30, 30000, 10 );
totalAltitudes = length( initialAltitude );

% Clock shift
% clockShift = 0;
clockShift = linspace( -1000, 1000, 5 );
clockShift = 0;
% clockShift = [ 0, 0 ];
% clockShift = 15*(0:10);

totalClockShifts = length( clockShift );

% Aspect angle
aspectAngles = pi/4;
% aspectAngles = linspace( 0, pi/2, 5 );
totalAspectAngles = length( aspectAngles );

% Sigma Noise
%sigmaNoise = 1e-3;
% sigmaNoise = logspace( -13, -8, 6 );
sigmaNoise = [ 1e-11, 1e-9, 1e-7, 1e-5, 1e-3 ];
sigmaNoise = [1e-9, 1e-7, 1e-5];
sigmaNoise = logspace( -20, -3, 18 );
%sigmaNoise = sigmaNoise(1:5:end);
%sigmaNoise = sigmaNoise(sigmaNoise<=1e-7);
totalSigmas = length( sigmaNoise );

% Fast time windows
totalPeriods = 50;
%totalPeriods = 5;
numberPeriods = round( logspace( 1, 5, totalPeriods ) );
%numberPeriods = 10.^(2+0.0395*(0:100));
% numberPeriods = 1000:1000:10000;
totalPeriods = length( numberPeriods );

totalMethods = 1;
saveDirectory = '/wavedata/poliann/mat_all_new';

% Array speed
%arraySpeed = 4 .* 10.^(0:5);
arraySpeed = 40;
totalSpeeds = length( arraySpeed );

% Array perturbations
arrayPerturbations = struct( 'i', 1, 'j', 1, 'dx', 0, 'dy', 0 );


parfor iPeriod = 1 : totalPeriods
    for jAltitude = 1 : totalAltitudes
        for kClock = 1 : totalClockShifts
            for lAngle = 1 : totalAspectAngles
                for mSigma = 1 : totalSigmas
                    for nSpeed = 1 : totalSpeeds
                        test_doa_methods_all( ...
                            numberPeriods(iPeriod), ...
                            initialAltitude(jAltitude), ...
                            clockShift(kClock), ...
                            aspectAngles(lAngle), ...
                            sigmaNoise(mSigma), ...
                            arraySpeed(nSpeed) ...
                            );
                    end
                end
            end
        end
    end
end

% simulationDims = [ totalPeriods, totalAltitudes, totalClockShifts, totalAspectAngles, totalSpeeds ];
% totalSimulations = prod( simulationDims );
% 
% parfor tSimulation = 1 : totalSimulations
% 	[iPeriod,jAltitude,kClock,lAngle,mSigma,nSpeed] = ind2sub( simulationDims, tSimulation );
% 	test_doa_methods_all( ...
%                             numberPeriods(iPeriod), ...
%                             initialAltitude(jAltitude), ...
%                             clockShift(kClock), ...
%                             aspectAngles(lAngle), ...
%                             sigmaNoise(mSigma), ...
%                             arraySpeed(nSpeed) ...
%                             );
% end

%%

angleEstimationErrorNorm = nan( 2, totalSigmas, totalPeriods, totalMethods );
angleEstimations = nan( 2, totalSigmas, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );

dataSnrs = nan( totalSigmas, 1 );

for mSigma = 1 : totalSigmas
    thisArraySpeed = arraySpeed;
    for iPeriod = 1 : totalPeriods
        if isscalar( thisArraySpeed ) || thisArraySpeed(2) == 0
            filename = sprintf( ...
                'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f_%.8f.mat', ...
                numberPeriods(iPeriod), initialAltitude, clockShift, aspectAngles, log10(sigmaNoise(mSigma)), thisArraySpeed,  mean( arrayPerturbations.dx ) );
        else
            filename = sprintf( ...
                'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f-%.2f_%.8f.mat', ...
                numberPeriods(iPeriod), initialAltitude, clockShift, aspectAngles, log10(sigmaNoise(mSigma)), thisArraySpeed(1), thisArraySpeed(2),  mean( arrayPerturbations.dx ) );
        end
        filename = fullfile( saveDirectory, filename );
        savedResults = load( filename );
        for nMethod = 1 : totalMethods
            methodNames{nMethod} = savedResults.methodDescriptions{nMethod}{2};
            halfNumberPeriods = round(numberPeriods(iPeriod)/2);
            anglesTrue = savedResults.anglesTrue(:,:,halfNumberPeriods);
            %anglesTrue = savedResults.anglesTrue(:,:,1);
            anglesEstimated = savedResults.anglesEstimated(:,:,nMethod);
            
            % angleEstimationErrorNorm(:,kClock,iPeriod,nMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
            angleEstimationErrorNorm(:,mSigma,iPeriod,nMethod) = abs( anglesEstimated - anglesTrue );
            angleEstimations(:,mSigma,iPeriod,nMethod) = rad2deg(anglesEstimated);
            
            dataSnrs(mSigma) = savedResults.dataSNR;
        end
    end
end



%%

numberPeriodsOptimal = nan( totalSigmas, 2 );
errorOptimal = nan( totalSigmas, 2 );

% speedAngleLabel = [ ...
%     '_v_', ...
%     num2str( arraySpeed ), ...
%     '_a_', ...
%     num2str( aspectAngles ), ...
%     '_h_', ...
%     num2str( initialAltitude ) ];

velSClockshiftAngleLabel = sprintf( ...
    'v_%.0f_csh_%.0f_a_%.2f_h_%.0f',...
    arraySpeed, ...
    clockShift, ...
    aspectAngles, ...
    initialAltitude );


for mSigma = 1 : totalSigmas
    [numberPeriodsOptimal(mSigma,1),errorOptimal(mSigma,1)] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,mSigma,:,1) ) );
    [numberPeriodsOptimal(mSigma,2),errorOptimal(mSigma,2)] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,mSigma,:,1) ) );
end

fastTimePeriod = 1e-9;

%%%%%%%%%%%%%%%%%%%
figure( 'Visible', 'On' )
subplot( 2, 1, 1 )
plotError1 = loglog( ...
    numberPeriods*fastTimePeriod, squeeze( angleEstimationErrorNorm(1,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError1(arraySpeed==40), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
%ylim( [0 7e-7] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Angle estimation RMS error [rad]' )
title( 'Angle estimation error \epsilon_{\theta_x} as function of SNR' )
orient landscape
snrLabels = arrayfun( @(f) [num2str(round(f)), ' dB'], dataSnrs, ...
    'UniformOutput', false );
legend( snrLabels{:}, 'Location', 'SouthWest' )

subplot( 2, 1, 2 )
plotError2 = loglog( ...
    fastTimePeriod*numberPeriods, squeeze( angleEstimationErrorNorm(2,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError2(arraySpeed==40), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Angle estimation RMS error' )
title( 'Angle estimation error \epsilon_{\theta_y} as function of SNR' )
orient landscape

legend( snrLabels{:}, 'Location', 'SouthWest' )
superLabel = sprintf( ...
    'v=%.0f m/s, alpha=%.2f rad, H=%.0f m',...
    arraySpeed, ...
    aspectAngles, ...
    initialAltitude );
suptitle( superLabel )
orient landscape
print( ['html/error_tau_snr', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )

%%%%%%%%%
figureTotalError = figure( 'Visible', 'On' )
plotTotalError = loglog( ...
    fastTimePeriod*numberPeriods, squeeze( mean( angleEstimationErrorNorm(:,:,:,1), 1 ) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError2(arraySpeed==40), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Angle estimation RMS error' )
title( 'Angle estimation error as function of SNR' )
orient landscape

legend( snrLabels{:}, 'Location', 'EastOutside' )
print( figureTotalError, ...
	[ 'html/total_error_tau_snr', velSClockshiftAngleLabel, '.pdf' ], ...
	'-dpdf' )


%%%%%%%%%%%%%%%%%%
figure( 'Visible', 'On' )
subplot( 2, 1, 1 )
plotError1 = semilogx( ...
    numberPeriods*fastTimePeriod, squeeze( angleEstimations(1,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError1(arraySpeed==40), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
%ylim( [0 7e-7] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Estimated angle [deg]' )
ylim( [-10 10] )
title( 'Estimated angle \theta_x as function of SNR' )
orient landscape
%clockShiftLabels = arrayfun( @(f) [num2str(f), ' Hz'], clockShift, ...
%    'UniformOutput', false );
legend( snrLabels{:}, 'Location', 'SouthWest' )

subplot( 2, 1, 2 )
plotError2 = semilogx( ...
    fastTimePeriod*numberPeriods, squeeze( angleEstimations(2,:,:,1) ), ...
    '-', ...
    'LineWidth', 2, ...
    'MarkerFaceColor', 'auto' );
%set( plotError2(arraySpeed==40), 'LineWidth', 5 )

grid on
%xlim( [1e1 1e5] )
xlabel( 'Fast time recording window [s]' )
ylabel( 'Estimated angle [deg]' )
ylim( [-10 10] )
title( 'Estimated angle \theta_y as function of SNR' )
orient landscape

legend( snrLabels{:}, 'Location', 'SouthWest' )
% % superLabel = sprintf( ...
% %     'v=%.0f m/s, alpha=%.2f rad, H=%.0f m, SNR=%.0f dB',...
% %     arraySpeed, ...,
% %     aspectAngles, ...
% %     initialAltitude, ...
% %     savedResults.dataSNR );
suptitle( superLabel )
orient landscape
print( ['html/angle_tau_snr', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )


 
figure( 'Visible', 'On' )
semilogy( dataSnrs, errorOptimal(:,1), '-o', 'LineWidth', 2, 'MarkerFaceColor', 'auto' )
xlabel( 'SNR [dB]' )
ylabel( 'Minimum error [rad]' )
title( 'Minimum angle estimation error' )
suptitle( superLabel )
grid on
orient landscape 
print( ['html/optimal_error_snr', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )

 
 figure( 'Visible', 'On' )
 plot( dataSnrs, fastTimePeriod * numberPeriodsOptimal(:,1), '-o', 'LineWidth', 2, 'MarkerFaceColor', 'auto' )
 xlabel( 'SNR [dB]' )
 ylabel( 'Fast time recording window [s]' )
 title( 'Optimal fast time window' )
 suptitle( superLabel )
 grid on
 orient landscape, 
 print( ['html/optimal_tau_snr', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )
 save( fullfile( saveDirectory, 'plot_snr.mat' ), '-v7.3' )

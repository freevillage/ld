SetDefaultFigureProperties


% Altitude
initialAltitude = 3000;
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
sigmaNoise = 1e-5;
% sigmaNoise = logspace( -13, -8, 6 );
%sigmaNoise = [ 1e-11, 1e-9, 1e-7, 1e-5, 1e-3 ];
% sigmaNoise = [1e-9, 1e-7, 1e-5];
% sigmaNoise = logspace( -9, -3, 50 );
% sigmaNoise = sigmaNoise(1:5:end);
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
saveDirectory = '/scratch/poliann/mat_all_new';

% Array speed
%arraySpeed = 4 .* 10.^(0:5);
arraySpeed = 40;
totalSpeeds = length( arraySpeed );

% Array pertturbations
ip = [ones(1,15),1:15];
jp = [1:15,ones(1,15)];
dxp = 0.01 * ones( size( ip ) );
dyp = 0.01 * ones( size( jp ) );

sigmaArrayPerturbation = logspace( -15, 1, 17 );
totalArrayPerturbations = length( sigmaArrayPerturbation );

parfor iPeriod = 1 : totalPeriods
    for jAltitude = 1 : totalAltitudes
        for kClock = 1 : totalClockShifts
            for lAngle = 1 : totalAspectAngles
                for mSigma = 1 : totalSigmas
                    for nSpeed = 1 : totalSpeeds
                        for oPerturbation = 1 : totalArrayPerturbations
                            test_doa_methods_all( ...
                                numberPeriods(iPeriod), ...
                                initialAltitude(jAltitude), ...
                                clockShift(kClock), ...
                                aspectAngles(lAngle), ...
                                sigmaNoise(mSigma), ...
                                arraySpeed(nSpeed), ...
                                struct( 'i', ip, 'j', jp, ...
                                    'dx', sigmaArrayPerturbation(oPerturbation) * dxp, ...
                                    'dy', sigmaArrayPerturbation(oPerturbation) * dyp ) ...
                                );
                        end
                    end
                end
            end
        end
    end
end

%%

angleEstimationErrorNorm = nan( 2, totalArrayPerturbations, totalPeriods, totalMethods );
angleEstimations = nan( 2, totalArrayPerturbations, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );

% dataSnrs = nan( totalSigmas, 1 );

for oPerturbation = 1 : totalArrayPerturbations
    thisArraySpeed = arraySpeed;
    for iPeriod = 1 : totalPeriods
        if isscalar( thisArraySpeed ) || thisArraySpeed(2) == 0
            filename = sprintf( ...
                'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f_%.8f.mat', ...
                numberPeriods(iPeriod), initialAltitude, clockShift, aspectAngles, log10(sigmaNoise), thisArraySpeed, 0.01 * sigmaArrayPerturbation(oPerturbation)  );
        else
            filename = sprintf( ...
                'test_doa_results_%.0f_%.2f_%.2f_%.2f_%.2f_%.2f-%.2f_%.8f.mat', ...
                numberPeriods(iPeriod), initialAltitude, clockShift, aspectAngles, log10(sigmaNoise), thisArraySpeed(1), thisArraySpeed(2), 0.01 * sigmaArrayPerturbation(oPerturbation) );
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
            angleEstimationErrorNorm(:,oPerturbation,iPeriod,nMethod) = abs( anglesEstimated - anglesTrue );
            angleEstimations(:,oPerturbation,iPeriod,nMethod) = rad2deg(anglesEstimated);
            
            %dataSnrs(mSigma) = savedResults.dataSNR;
        end
    end
end



%%

numberPeriodsOptimal = nan( totalArrayPerturbations, 2 );
errorOptimal = nan( totalArrayPerturbations, 2 );

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


for oPerturbation = 1 : totalArrayPerturbations
    [numberPeriodsOptimal(oPerturbation,1),errorOptimal(oPerturbation,1)] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,oPerturbation,:,1) ) );
    [numberPeriodsOptimal(oPerturbation,2),errorOptimal(oPerturbation,2)] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,oPerturbation,:,1) ) );
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
ylabel( 'Angle estimation error [rad]' )
title( 'Angle estimation error \epsilon_{\theta_x} as function of antenna shift' )
orient landscape
arrayPerturbationLabels = arrayfun( @(f) [num2str(f), '%'], sigmaArrayPerturbation, ...
    'UniformOutput', false );
legend( arrayPerturbationLabels{:}, 'Location', 'SouthWest' )

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
ylabel( 'Angle estimation error' )
title( 'Angle estimation error \epsilon_{\theta_y} as function of antenna shift' )
orient landscape

legend( arrayPerturbationLabels{:}, 'Location', 'SouthWest' )
superLabel = sprintf( ...
    'SNR=%.0f dB, alpha=%.2f rad, H=%.0f m',...
    savedResults.dataSNR, ...
    aspectAngles, ...
    initialAltitude );
suptitle( superLabel )
orient landscape
print( ['html/error_tau_antenna_shift', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )

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
legend( arrayPerturbationLabels{:}, 'Location', 'SouthWest' )

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
title( 'Estimated angle \theta_y as function of antenna shift' )
orient landscape

legend( arrayPerturbationLabels{:}, 'Location', 'SouthWest' )
% % superLabel = sprintf( ...
% %     'v=%.0f m/s, alpha=%.2f rad, H=%.0f m, SNR=%.0f dB',...
% %     arraySpeed, ...,
% %     aspectAngles, ...
% %     initialAltitude, ...
% %     savedResults.dataSNR );
suptitle( superLabel )
orient landscape
print( ['html/angle_tau_array_perturbation', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )

%%%%%%%%%%%%%%
figureTotalError = figure( 'Visible', 'on' );
plotTotalError = loglog( ...
	fastTimePeriod * numberPeriods, squeeze( mean( angleEstimationErrorNorm(:,:,:,1), 1 ) ), ...
	'-', ...
	'LineWidth', 2, ...
	'MarkerFaceColor', 'auto' );
grid on
xlabel( 'Fast time recoring window [s]' )
ylabel( 'Angle estimation error [deg]' )
title( 'Angle estimation error as function of antenna shift' )
orient landscape
legend( arrayPerturbationLabels{:}, 'Location', 'EastOutside' )
print( figureTotalError, ...
	[ 'html/total_error_tau_array_perturbation', velSClockshiftAngleLabel, '.pdf' ], ...
	'-dpdf' )

%%%%%%%%% 
figure( 'Visible', 'On' )
loglog( sigmaArrayPerturbation, errorOptimal(:,1), '-o', 'LineWidth', 2, 'MarkerFaceColor', 'auto' )
xlabel( 'Antenna shift [%]' )
ylabel( 'Minimum error [rad]' )
title( 'Minimum angle estimation error' )
suptitle( superLabel )
grid on
orient landscape 
print( ['html/optimal_error_array_perturbation', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )

 
 figure( 'Visible', 'On' )
 plot( sigmaArrayPerturbation, fastTimePeriod * numberPeriodsOptimal(:,1), '-o', 'LineWidth', 2, 'MarkerFaceColor', 'auto' )
 xlabel( 'Antenna shift [%]' )
 ylabel( 'Fast time recording window [s]' )
 title( 'Optimal fast time window' )
 suptitle( superLabel )
 grid on
 orient landscape, 
 print( ['html/optimal_tau_array_perturbation', velSClockshiftAngleLabel, '.pdf'], '-dpdf' )
 save( fullfile( saveDirectory, 'plot_array_perturbation.mat' ), '-v7.3' )

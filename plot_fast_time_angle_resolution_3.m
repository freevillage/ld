totalPeriods = 20;
totalAngles = 1;
totalMethods = 4;
saveDirectory = '/scratch/poliann/mat_angle';

numberPeriods = round( logspace( 3, 4, totalPeriods ) );
angles = pi/4;

% angles = angles(length(angles)/2 + 1 : end);
% totalAngles = length( angles );

%%

for jAngle = 1 : totalAngles
    for iPeriod = 1 : totalPeriods
        test_doa_methods_angle( numberPeriods(iPeriod), angles(jAngle) )
    end
%     plot_doa_resolution_results
    
end

%%

angleEstimationErrorNorm = nan( 2, totalAngles, totalPeriods, totalMethods );
methodNames = cell( totalMethods, 1 );


for jAngle = 1 : totalAngles
    for iPeriod = 1 : totalPeriods
        filename = fullfile( saveDirectory, sprintf( 'test_doa_results_%.0f_%.0f.mat', numberPeriods(iPeriod),  log10( angles(jAngle) ) ) );
        savedResults = load( filename );
        for kMethod = 1 : totalMethods
            methodNames{kMethod} = savedResults.methodDescriptions{kMethod}{2};
            anglesTrue = savedResults.anglesTrue(:,:,1);
            anglesEstimated = savedResults.anglesEstimated(:,:,kMethod);
            
            angleEstimationErrorNorm(:,jAngle,iPeriod,kMethod) = sqrt( sum( transpose( abs( anglesEstimated - anglesTrue ) ) ) .^2 );
        end
    end
end



%%

numberPeriodsOptimal = nan( totalAngles, 2 );

for jAngle = 1 : totalAngles
    [numberPeriodsOptimal(jAngle,1),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(1,jAngle,:,1) ) );
    [numberPeriodsOptimal(jAngle,2),~] = FindMinimum( numberPeriods, squeeze( angleEstimationErrorNorm(2,jAngle,:,1) ) );
end

 figure( 'Visible', 'Off' )
 loglog( angles, numberPeriodsOptimal, '-o' )
 xlabel( 'SNR' )
 ylabel( 'Fast time recording window [periods]' )
 title( 'Optimal fast time window' )
 grid on
 orient landscape, 
 print -dpdf html/optimal_tau_angle
 save( fullfile( saveDirectory, 'plot_angle.mat' ), '-v7.3' )
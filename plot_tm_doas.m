% loglog( ...
%     sigmaNoise, sum((locationsL2-sourcePosition * ones(1,totalSigmas )).^2), '-o', ...
%     sigmaNoise, arrayfun( @(s) test_sliding_window(20,s), sn ), '-d', ...
%     'LineWidth', 2, 'MarkerFaceColor', 'auto' )


SetDefaultFigureProperties

windows = 5:20;
totalWindows = length( windows );

sigmaNoise = 10.^(-13:-3);
totalSigmas = length( sigmaNoise );

slidingError = nan( totalWindows, totalSigmas );

for iw = 1 : totalWindows
    for js = 1 : totalSigmas
        slidingError(iw,js) = CacheResults( @test_sliding_window, { windows(iw), sigmaNoise(js) } );
    end
end

figure 
loglog( ...
    sigmaNoise, sum((locationsL2-sourcePosition * ones(1,totalSigmas )).^2), '-o', ...
    sigmaNoise, slidingError(1:5:end,:), '-d', ...
    'LineWidth', 2, 'MarkerFaceColor', 'auto' )
windowLabels = [ 'Template matching', arrayfun( @num2str, windows(1:5:end), 'UniformOutput', false ) ];
legendWindows = legend( windowLabels{:}, 'Location', 'SouthEast' );
title( legendWindows, 'Window size' )
grid on
xlabel( '\sigma_{noise}' )
ylabel( 'Location error [m]' )
title( 'Location from a single slow time using template matching and DOA' )

figure
semilogy( windows, transpose(slidingError(:,4:end-2)), ...
    '-o', 'LineWidth', 2, 'MarkerFaceColor', 'auto' )
sigmaLabels = arrayfun( @num2str, sigmaNoise(4:end-2), 'UniformOutput', false );
legendSigmas = legend( sigmaLabels{:} );
title( legendSigmas, '\sigma_{noise}' )
xlabel( 'Window size' )
ylabel( 'Location error [m]' )
title( 'Location using DOAs estimated from rows and columns' )
grid on
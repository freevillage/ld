%% Estimating discrete frequency spectrum


%% Construct powersum observations 
%%
% $y_n = \sum\limits_{k=1}^K c_k z_k^n + \sigma_n e^{2\pi i w_n}, \quad z_k=e^{-i\pi \theta_k},\quad w_n \sim U[0,1], \quad n\in \{0,\ldots,N-1\}$
N = 501;
n = (0:N-1)';
theta_k = [ 0.4 0.2 0.8 ]';  % angles in rad
theta_k = [ -0.2 ];
z_k = exp(-1i*pi*theta_k);
c_k = [ 1 0.3 -0.2 ]';
c_k = [ 1 ];
K = length(z_k);     % how many components in the signal
A = kron(ones(N,1), z_k').^kron(n, ones(1,K));
x_n = A*c_k;

%% Add noise if necessary

sigma_n = 1e-5;
y_n = x_n + sigma_n*exp(2*pi*1i*rand(size(x_n)));
y_n = x_n + sigma_n * ( randn(size(x_n)) + 1i * randn(size(x_n)) ); 
u_n = y_n;      % observation


%% Show true phases
truePhases = ToRow( sort( WrapToOne( theta_k ) ) );
fprintf( '\n\n%25s: %s\n\n', ...
        'True', ...
        num2str( truePhases, '%+10f' ) );

%% Calculate and show estimated phases
supportedMethods = { ...
    'Prony', ...
    'TotalLeastSquaresProny', ...
    'CorrelationSinglePhase', ...
    'RootMusic', ...
    'MatrixPencil', ...
    'Music', ...
...%   'Esprit' ...
    'MaximumLikelihoodSinglePhase'
    };

totalMethods = length( supportedMethods );

figure
subplot( 1, 2, 1 ), hold on
plot( truePhases, '-o', 'LineWidth', 3 );

for iMethod = 1 : totalMethods
    methodName = supportedMethods{iMethod};
    tic
    estimatedPhases = ToRow( sort( DiscreteFrequencySpectrum( u_n, ...
        'TotalFrequencies', K, ...
        'Method', methodName, ...
        'NoiseStandardDeviation', sigma_n ) ) );
    toc
    fprintf( '%30s: %s\n', ...
        methodName, ...
        num2str( estimatedPhases, '%+10f' ) );
    plot( estimatedPhases )
end

plotLegends = [ { 'True' }, supportedMethods ];
legend( plotLegends, 'Location', 'SouthEast' )
ylim( [-1 1] )
title( 'Phase estimation' )
xlabel( 'Phase number' )
ylabel( 'Phase' )

subplot( 1, 2, 2 )
hold on

estimationErrors = nan( 1, totalMethods );

for iMethod = 1 : totalMethods
    methodName = supportedMethods{iMethod};
    estimatedPhases = ToRow( sort( DiscreteFrequencySpectrum( u_n, ...
        'TotalFrequencies', K, ...
        'Method', methodName ) ) );
    estimationError = estimatedPhases - truePhases;
    estimationErrors(iMethod) = estimationError;
    plot( estimationError )
end

legend( supportedMethods, 'Location', 'SouthEast' )
title( 'Estimation errors' )
xlabel( 'Phase number' )
ylabel( 'Phase' )


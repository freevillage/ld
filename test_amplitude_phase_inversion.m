%% Estimating discrete frequency spectrum


%% Construct powersum observations 
%%
% $y_n = \sum\limits_{k=1}^K c_k z_k^n + \sigma_n e^{2\pi i w_n}, \quad z_k=e^{-i\pi \theta_k},\quad w_n \sim U[0,1], \quad n\in \{0,\ldots,N-1\}$
N = 501;
n = (0:N-1)';
theta_k = [ 0.4 0.2 0.8 ]';  % angles in rad
theta_k = [ 0.3 ];
z_k = exp(-1i*pi*theta_k);
c_k = [ 1 0.3 -0.2 ]';
c_k = [ 1 ];
K = length(z_k);     % how many components in the signal
A = kron(ones(N,1), z_k').^kron(n, ones(1,K));
x_n = A*c_k;

%% Add noise if necessary

sigma_n = 3;
y_n = x_n + sigma_n*exp(2*pi*1i*rand(size(x_n)));
u_n = y_n;      % observation

%% ML estimation of amplitude and phase
AfOptimal = DFSMaxLikelihoodSingleAmplitudePhaseSingleSnapshot( y_n, sigma_n )

plot( n, x_n, n, y_n )
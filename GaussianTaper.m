function window = GaussianTaper( N, epsilon )
%GAUSSIANTAPER Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    epsilon = eps;
end

WindowFcn = @(x,sigma) exp( - ( x - (N+1)/2 ) .^ 2 / (2 * sigma^2) );

sigmaGuess = N/16;
sigmaOptimal = fzero( @(sigma) WindowFcn( N, sigma ) - epsilon, sigmaGuess );

window = arrayfun( @(n) WindowFcn(n,sigmaOptimal), 1:N );

end



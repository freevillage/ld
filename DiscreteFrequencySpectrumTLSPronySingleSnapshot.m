function w_hat = DiscreteFrequencySpectrumTLSPronySingleSnapshot(y,K,L)
% n = number of components
% L = conditioning size of matrix

% actually gives n estimates, the previous version was wrong 
% seems broken -- paper seems incorrect altogether

if nargin == 2
    L = K;
end

y = y(:);
N = length(y);
n = (0:N-1)';

%% estimation parameter
%% TLS part
% Ymat = hankel(y(1:L), y(L:N))';
Ymat = hankel( y(1:N-L), y(N-L:end).' );
[U,S,V] = svd(Ymat);        % svd decomposition
Sd = S;                     % look at singular values
Sd(L+1:end, L+1:end) = 0;   % svd denoising
Yden = U*Sd*V';             % denoised matrix
yd = Yden(:,1);             % denoised "LP"
Pd = Yden(:,2:end);         % denoised "data"
% b_hat = -Pd\yd;         % LinPred coeffs
b_hat = -pinv(Pd)*yd;       % LinPred coeffs
b_hat = [1; b_hat(:)];
% b_hat = b_hat(end:-1:1);
% y_d = [Ymat_d(:,1)];        % Ymat_d(end,2:end)'];
% b_hat = -pinv(Ymat_d)*y_d;

%% map to our parameters
if(length(b_hat)>1)
%     u_guess = conj((roots(b_hat)));
    u_guess = 1./(roots(b_hat));
else
    u_guess = (b_hat);
end
u_guess = u_guess(:);
A_guess = ( ones(N,1)*u_guess.' ) .^ ( n*ones(size(u_guess.')) );
%%% estimate coefficients
c_guess = y\A_guess;
%%% 
[conf, guess] = sort(abs(c_guess));
c_hat = c_guess(guess(1:K));
u_hat = u_guess(guess(1:K));

w_hat = sort( WrapToOne( mod( angle( u_hat ), 2*pi ) / pi ) );


end % of function 
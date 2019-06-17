% developing the TLS-prony method
% julius kusuma <kusuma@mit.edu>
% 070177

% June 21, 2008:  This version appears to actually work for K=1!
% June 21, 2008:  Start development for K>1.  This version seems to work.

clear all;
format long;

%% signal parameter
c = [1 1]';
u = [-0.9 0.6]';
u = exp(j*u);
K = length(u);
N = 16;  L = 2;
sig = 0.0001;

%% generate signal
n = (0:N-1)';
A = ( ones(N,1)*u.' ) .^ ( n*ones(1,K) );
x = A * c;
y = x + sig*randn(size(x));

% %% try an older script
% [u_hat] = TLSPronyC(y, K, L)


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
u = u(:);  u_guess = u_guess(:);
A_guess = ( ones(N,1)*u_guess.' ) .^ ( n*ones(size(u_guess.')) );
%%% estimate coefficients
c_guess = y\A_guess;
%%% 
[conf, guess] = sort(abs(c_guess));
c_hat = c_guess(guess(1:K));
u_hat = u_guess(guess(1:K));

% err = (u-u_hat).^2;

%% show results
figure(1);
drawcircle;
hold on;
plot(real(u), imag(u), 'ko');
plot(real(u_guess), imag(u_guess), 'bd' );
plot(real(u_hat), imag(u_hat), 'rx' );
hold off;
axis([-2 2 -2 2]);
grid;



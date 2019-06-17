% basic prony method

clear all;
format long;

%% signal parameter
c = [1 1]';
u = [0.2 1]';
% u = exp(j*u);
K = length(u);
N = 16;  L = 4;
sig = 0.01;
sig = 0;

%% generate signal
n = (0:N-1)';
A = ( ones(N,1)*u.' ) .^ ( n*ones(1,K) );
x = A * c;
y = x + sig*randn(size(x));


%% estimation of parameter
Ymat = hankel(y(K:2*K-1), y(2*K-1:-1:K).' );
yvec = y(K+1:2*K);
b_hat = -Ymat\yvec;

%% map to our parameters
if(length(b_hat)>1)
%     u_guess = (roots(b_hat));
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



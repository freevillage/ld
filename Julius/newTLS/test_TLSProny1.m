% developing the TLS-prony method
% julius kusuma <kusuma@mit.edu>
% 070177

% June 21, 2008:  This version appears to actually work for K=1!
% June 21, 2008:  Start development for K>1.  This version seems to work.

clear all;
format long;

%% signal parameter
c = [1]';
u = [0.4]';
u = exp(-1j*pi*u);
K = length(u);
N = 16;  L = 2;
sig = 0.01;

%% generate signal
n = (0:N-1)';
A = ( ones(N,1)*u.' ) .^ ( n*ones(1,K) );
x = A * c;
y = x + sig*randn(size(x));

%% new script
[u_hat] = newTLSProny(y, K, L);

% err = (u-u_hat).^2;

%% show results
figure(1);
drawcircle;
hold on;
plot(real(u), imag(u), 'ko');
% plot(real(u_guess), imag(u_guess), 'bd' );
plot(real(u_hat), imag(u_hat), 'rx' );
hold off;
axis([-2 2 -2 2]);
grid;

sort( mod( -angle( u_hat ), 2*pi ) / pi )


% developing the TLS-prony method
% julius kusuma <kusuma@mit.edu>
% 070177

% June 21, 2008:  This version appears to actually work for K=1!
% June 21, 2008:  Start development for K>1.  This version seems to work.

clear all;
format long;

%% simulation parameter
Ntrials = 1024;

%% signal parameter
c = [1 1 1 1]';
u = [-0.2 0.9 -1.4 0.4]';
% u = exp(j*u);
K = length(u);
N = 16;  L = K;
sig = 0.01;

%% generate signal
n = (0:N-1)';

%% new script
u_hat = zeros(K, Ntrials);
for trial = 1:Ntrials
    A = ( ones(N,1)*u.' ) .^ ( n*ones(1,K) );
    x = A * c;
    y = x + sig*randn(size(x));
    [u_hat(:,trial)] = newTLSProny(y, K, L);
end

% err = (u-u_hat).^2;

%% show results
figure(1);
drawcircle;
hold on;
% plot(real(u_guess), imag(u_guess), 'bd' );
plot(real(u_hat), imag(u_hat), 'rx' );
plot(real(u), imag(u), 'kd');
hold off;
axis([-2 2 -2 2]);
grid;



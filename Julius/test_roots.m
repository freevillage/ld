%% playing around with roots (complex roots on unity or real) in
%% powersum series
%
% julius kusuma <kusuma@mit.edu>
%
% 070405:  works but only for |z_k| < 1
% 061406:  check whether this works for all z_k \in \Real
% 080106:  playing around with performance
% 080206:  seems to work for both real and complex

clear all;

%% STEP 1:  construct powersum observations, observe y_n = \sum_k c_k z_k^n + noise
N = 15;
n = (0:N-1)';
% z_k = [ 0.4 0.6 ]';
w_k = [ 0.2 1.5 ]';  % angles in rad
z_k = exp(-1i*pi*w_k);
c_k = [ 1 1 ]';
sig = 0.01;
K = length(z_k);     % how many components in the signal

A = kron(ones(N,1), z_k').^kron(n, ones(1,K));
x_n = A*c_k;
y_n = x_n + sig*randn(size(x_n));
u_n = y_n;      % observation


%% STEP 2:  regularize
Mx = N-K;
Nx = K;
X1 = hankel(u_n(1:Mx), u_n(Mx:Mx+Nx-1));     % Hankel version
X2 = toeplitz(u_n(K+1:end), u_n(K+1:-1:1) );    % toeplitz
%Mx = size(X,1);  Nx = size(X,2);

Xa = X1(:,1:end-1); % selected matrix a
Xb = X1(:,2:end);   % selected matrix b

%% STEP 4:  find roots
[U,S,V] = svd(X1);
Us = U(:,1:K);
U1 = Us(1:end-1,:);
U2 = Us(2:end,:);
Z = pinv(U1)*U2;
rts = conj(eig(Z));

% show results for the 'rot' method
z_k = sort(z_k);
rts = sort(rts);

% show results for the 'annihilating' method
[Uu,Ss,Vv] = svd(X2);
rts2 = sort(conj(roots(Vv(:,end))));


% show results for real values
% z_k
% rts
% rts2


% show results for angles
w_k
w_hat1 = sort(mod(-angle(rts),2*pi)/pi)
w_hat2 = sort(mod(-angle(rts2),2*pi)/pi)

w_hat3 = TLSPronyC( u_n, K)
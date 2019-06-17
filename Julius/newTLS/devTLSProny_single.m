% developing the TLS-prony method
% julius kusuma <kusuma@mit.edu>
% 070177

% June 21, 2008:  This version appears to actually work!

clear all;

% signal parameter
c = 1;
u = 0.2;
N = 16;  L = 2;
sig = 0.0001;

% generate signal
n = (0:N-1)';
x = c*u.^n;
y = x + sig*randn(size(x));

% estimation parameter
Ymat = hankel(y(1:L), y(L:N))';
[U,S,V] = svd(Ymat);
S_d = zeros(size(S));
S_d(1,1) = S(1,1);
Ymat_d = U*S_d*V;
y_d = [Ymat_d(:,1)]; % Ymat_d(end,2:end)'];
b_hat = -pinv(Ymat_d)*y_d;
if(length(b_hat)>1)
    u_hat = abs(roots(b_hat));
else
    u_hat = abs(b_hat);
end
err = (u-u_hat)^2
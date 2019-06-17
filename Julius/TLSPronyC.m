function [w_hat, c_hat] = TLSPronyC(y,n,L)
% n = number of components
% L = conditioning size of matrix

% actually gives n estimates, the previous version was wrong 
% seems broken -- paper seems incorrect altogether

y = y(:);
N = length(y);
if nargin == 1
    n = 1;
    L = 2;
elseif nargin == 2
    L = n+1;
end

% estimation parameter
Ymat = hankel(y(1:L), y(L:N))';
[U,S,V] = svd(Ymat);
S_d = zeros(size(S));
for k=1:n
    S_d(k,k) = S(k,k);
end
Ymat_d = U*S_d*V;
y_d = [Ymat_d(:,1)]; % Ymat_d(end,2:end)'];
b_hat = -pinv(Ymat_d)*y_d;
if(length(b_hat)>1)
    u_hat = 1./(roots(b_hat));
else
    u_hat = 1/(b_hat);
end

w_hat = sort( mod( -angle( u_hat ), 2*pi ) / pi );

omega = 0.6;
c = 1;
K = length( omega );
M = 1e2;
x = nan( M, 1 );
for m = 1 : M
    x(m) = 0;
    for k = 1 : K
        x(m) = x(m) + c(k) * exp( -1i * pi * omega(k) * m );
    end
end

MusicInversionSingleSnapshot( x, 1 )
tic, CorrelationInversionSinglePhase( x ), toc

% w = linspace( 0, 2, 1e6 );
% ci = nan( length( w ), 1 );
% for i = 1 : length(w)
%     ci(i) = CorrelationImaging( pi*w(i) );
% end
% 
% [~,iMax] = max( ci );
% w(iMax)


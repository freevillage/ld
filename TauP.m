function gatherTauP = TauP( gatherTX, tauAxis, pAxis, x0 )

assert( IsDataset( gatherTX ) ...
    && IsGraphAxis( tauAxis ) ...
    && IsGraphAxis( pAxis ) );

gatherTXInterpolant = Interpolant( gatherTX );
xAxis = gatherTX.Axes(2);

if nargin < 4
    x0 = xAxis.Min;
end

assert( IsNumericScalar( x0 ) );

% totalTaus = tauAxis.TotalPoints;
% totalPs = pAxis.TotalPoints;
% 
% gatherTauPValues = nan( totalTaus, totalPs );
% 
% for iTau = 1 : totalTaus
%     tau = tauAxis.Points(iTau);
%     for jP = 1 : totalPs
%         p = pAxis.Points(jP);
%         
%         integrand = @(x) gatherTXInterpolant( tau + p * ( x - x0 ), x );
%         gatherTauPValues(iTau,jP) = integral( integrand, xMin, xMax );
%     end
%     
% end


[ x, tau, p ] = ndgrid( xAxis.Points, tauAxis.Points, pAxis.Points );

gatherTauPValues = squeeze( trapz( xAxis.Points, gatherTXInterpolant( tau + p .* ( x - x0 ), x ) ) );

assert( all( ~isnan( gatherTauPValues(:) ) ) );

gatherTauP = DatasetNd( tauAxis, pAxis, gatherTauPValues );

end
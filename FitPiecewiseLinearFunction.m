function params = FitPiecewiseLinearFunction( x, y )

xInitial = mean( x );
kInitial = (y(end) - y(1)) / (x(end) - x(1));
bInitial = mean( y - kInitial*x );

initialGuess = [ xInitial, min(kInitial,0), bInitial, max(kInitial,0), bInitial ]';
initialGuess = rand(1,5);

lb = [ min(x), -1000, -1000, 0, -1000 ]';
ub = [ max(x), 0, 1000, 1000, 1000 ]';

options = optimoptions('lsqcurvefit','Algorithm','levenberg-marquardt');

% params = lsqcurvefit( @PiecewiseLinearFunction, initialGuess ,x, y,lb,ub, options);

params = lsqcurvefit( @PiecewiseLinearFunction, initialGuess ,x, y,[],[], options);


% options = optimoptions('fmincon','Display','iter');
% problem.options = options;
% problem.solver = 'fmincon';
% problem.objective = @(pp) FitFunction( pp, x, y );
% problem.x0 = initialGuess;
% problem.lb = 2*[ min(x), -1000, -1000, 0, -1000 ]';
% problem.ub = 2*[ max(x), 0, 1000, 1000, 1000 ]';
% 
% params = fmincon( problem );

end

function error = FitFunction( params, x, y )

x = ToRow(x);
y = ToRow(y);

x0 = params(1);
k1 = params(2);
b1 = params(3);
k2 = params(4);
b2 = params(5);

yPredicted = [k1 * x(x <= x0) + b1, k2 * x(x>x0) + b2 ];

error = norm( y - yPredicted );

end
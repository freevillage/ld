function y = PiecewiseLinearFunction( params, x )

x = ToRow(x);

x0 = params(1);
k1 = params(2);
b1 = params(3);
k2 = params(4);
b2 = params(5);

y = [k1 * x(x <= x0) + b1, k2 * x(x>x0) + b2 ];

end
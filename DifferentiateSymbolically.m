function derivativeHandle = DifferentiateSymbolically( functionHandle )

syms t
derivativeHandle = matlabFunction( diff( functionHandle( t ) ) );

end % of function

function y = LogDet( matrix )

y = 2 * sum( log( diag( chol( matrix ) ) ) );

end
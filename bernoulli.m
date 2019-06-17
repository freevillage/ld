function y = bernoulli( p, n )

x = rand( n, 1 );
y = double( x <= p );

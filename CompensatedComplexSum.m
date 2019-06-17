function y = CompensatedComplexSum( x )

MyCompensatedSum = @(x) CompensatedSum( x, 1, 'Knuth2' );

if ~isreal( x )
    y = complex( ...
        MyCompensatedSum( real( x ) ), ...
        MyCompensatedSum( imag( x ) ) ...
        );
else
    y = MyCompensatedSum( x );
end

end
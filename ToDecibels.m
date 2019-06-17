function xdB = ToDecibels( xMeasured, xReference )

if nargin < 2
    xReference = 1;
end

xdB = 10 * log10( xMeasured / xReference );

end
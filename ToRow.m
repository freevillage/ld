function xRow = ToRow( x )
% y = TOROW( x )
% Turns input into a row vector by applying y = transpose( ToColumn( x ) )

% Last updated on 07/22/2015
% (C) Oleg V. Poliannikov

if isrow( x )
    xRow = x;
else
    xRow = transpose( ToColumn( x ) );
end

end
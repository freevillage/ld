function xColumn = ToColumn( x )
% y = TOCOLUMN( x )
% Vectorizes the input array x by applying x(:) if necessary

% Last updated: 7/22/2015
% (C) Oleg Poliannikov

if iscolumn( x )
    xColumn = x;
else
    xColumn = x(:);
end

end
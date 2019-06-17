function varargout = FullScreen( fig )

if nargin == 0
    fig = gcf;
end

screenSize = get( 0, 'ScreenSize' );
set( fig, 'Position', [0 0 screenSize(3) screenSize(4)] );

if nargout == 0
    varargout = {};
elseif nargout == 1
    varargout{1} = fig;
else
    error( 'Too many output parameters!' );
end

end
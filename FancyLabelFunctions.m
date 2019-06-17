function [XLabelFancy, YLabelFancy, ZLabelFancy] = FancyLabelFunctions( varargin )

XLabelFancy = @(str) xlabel( str, varargin{:} );
YLabelFancy = @(str) ylabel( str, varargin{:} );
ZLabelFancy = @(str) zlabel( str, varargin{:} );

end
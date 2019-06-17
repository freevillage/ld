function CloseMatlabPool( varargin )

isPoolOpen = matlabpool( 'size' ) > 0;

if isPoolOpen
    matlabpool( 'close', varargin{:} );
end

end
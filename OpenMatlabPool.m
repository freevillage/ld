function OpenMatlabPool( varargin )

isPoolOpen = matlabpool( 'size' ) > 0;

if isPoolOpen
    warning( 'Matlab pool is already open. No additional action is performed' );
else
    matlabpool( 'open', varargin{:} );
end

end
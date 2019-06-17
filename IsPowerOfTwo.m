function Answer = IsPowerOfTwo( Numbers )

% This function uses the two-output form of the standard MATLAB routine
% log2. Type help log2 for more details.
[ F, E ] = log2( Numbers ); %#ok<NASGU>

% If a Number is a power of two then its corresponding F will be equal 0.5
Answer = false( size( Numbers ) );
Answer( F == 0.5 ) = true;

end % of IsPowerOfTwo
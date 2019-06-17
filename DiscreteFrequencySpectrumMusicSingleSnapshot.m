function phases = DiscreteFrequencySpectrumMusicSingleSnapshot( signal, totalPhases, frequencySensitivity, totalRefinements, refinementFactor )

signal = TrimToOddLength( signal );

if nargin < 3 || ( nargin == 3 && frequencySensitivity <= 0 )
    frequencySensitivity = 1e-5;
end

totalFrequencies = ceil( 1/frequencySensitivity );

Fnormalized = Bandspaces( [-0.5, 0.5], totalFrequencies );
FApproximate = FindPeaksInRange( signal, totalPhases, Fnormalized );
refinedBandThickness = 1;

for refinement = 1 : totalRefinements
    refinedBandThickness = refinedBandThickness / refinementFactor;
    Fnormalized  = Bandspaces( [ (ToColumn( FApproximate ) - refinedBandThickness), (ToColumn( FApproximate ) + refinedBandThickness) ], totalFrequencies );
    FApproximate = FindPeaksInRange( signal, totalPhases, Fnormalized );
end

phases = 2 * FApproximate;

end

function Fpeak = FindPeaksInRange( signal, totalPhases, Fnormalized )

I = ImagingFunction( Fnormalized, length(signal) - 1, NoiseSpace( signal, totalPhases ) );

Fpeak = sort( Fnormalized( FindLargestPeaks( I, totalPhases ) ) );

end
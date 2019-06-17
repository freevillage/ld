function directions = MusicDoa( arrayData, totalDirections, sourceFrequency, arraySpacing )

directions = asin( LightSpeed * MusicInversion( arrayData, totalDirections ) / ( 2*sourceFrequency*arraySpacing ) );

end % of function
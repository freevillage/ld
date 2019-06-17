function WriteLocationToFile( Location, Filename )

% Open file for writing in text format
OutputFile = fopen( Filename, 'wt+' );

% Write the total number of locations
fprintf( OutputFile, '%d\n', Location.TotalLocations ); 

% Then write all location coordinates 
for LocationNo = 1 : Location.TotalLocations
    fprintf( OutputFile, '%f %f\n', Location.X( LocationNo ), Location.Z( LocationNo ) );
end

% Close output file
fclose( OutputFile );

end
function status = FileClose( fileID )

if ~isempty( fopen( fileID ) )
    status = fclose( fileID );
end

end
function ClearFolder( folder )

allFilesInFolder = fullfile( folder, '*' );
delete( allFilesInFolder );

end
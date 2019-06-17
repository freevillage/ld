function ConvertAllSacsToMat( wildcard )

files = dir( wildcard );
filenames = {files.name};

totalFiles = length( filenames );
waitbar = ProgressBar;

for iFile = 1 : totalFiles
   sacFilename = filenames{iFile};
   matFilename = [ sacFilename, '.mat' ];
   ConvertSacToMat( sacFilename, matFilename );
   waitbar.SetProgress( iFile/totalFiles );
end

waitbar.Delete;

end
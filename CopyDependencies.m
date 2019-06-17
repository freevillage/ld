function CopyDependencies( programName, whereTo )

filesRequired = matlab.codetools.requiredFilesAndProducts( programName );
cellfun( @(filename) copyfile( filename, whereTo ), filesRequired );

end
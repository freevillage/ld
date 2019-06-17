function reflectionTime = NormalMoveout( reflectorDepth, geophoneOffset, velocity  )

reflectionTime = DipMoveout( reflectorDepth, zeros( size(reflectorDepth) ), geophoneOffset, velocity );

end
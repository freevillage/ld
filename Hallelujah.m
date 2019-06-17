function Hallelujah
% Hallelujah plays one work from the song with the same name. All other
% activity is on pause while the song is being played.

%   Copyright 2013 Oleg V. Poliannikov 
%   $Revision: 1.0.0.0 $  $Date: 2013/05/03 22:48:00 $

track = load( 'handel' );
player = audioplayer( track.y, track.Fs );
playblocking( player, [1 (get(player, 'SampleRate') * 2)] );

end
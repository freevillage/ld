format compact                    % tightens loose format
format long e                     % makes numerical output in double precision
theta = linspace(0,2*pi,100);     % create vector theta
x = cos(theta);                   % generate x-coordinate
y = sin(theta);                   % generate y-coordinate
plot(x,y);                        % plot circle
axis('equal');                    % set equal scale on axes per pixel
% title('Circle of unit radius')    % put title
% c=2*pi                            % prints out 2*pi value
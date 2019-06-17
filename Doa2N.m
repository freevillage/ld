%%
% output:
% n1 = first unit vector normal to unit vector of arrival
% n2 = second unit vector normal to unit vector of arrival
%
% input parameters:
% alpha = rotation angle about the x-axis
% beta = rotation angle about the y-axis
% gamma = rotation angle about the z-axis
% psi_x = direction of arrival with respect to x-axis
% psi_y = direction of arrival with respect to y-axis
%

% Directions of Arrival to Normal Vectors
% Sang Min Han
% 07/10/2015

function [n1, n2, k] = Doa2N( alpha, beta, gamma, psi_x, psi_y )


%% Approach 1
% adjust the direction of arrival from ura orientation
R= RotationMatrix(alpha, beta, gamma);
theta_x= pi/2 - psi_x;
theta_y= pi/2 - psi_y;
k= [cos(theta_x); cos(theta_y); 0];
k(3)= real(-1*sqrt(1 - sum(k.^2))); % address z pointing direction
k= R*k;

% assume flat Earth
% rad= -1*arrayPosition(3)/k(3);
% k= rad*k;

n1= [-k(2); k(1); 0];
n2= cross(k,n1);

end

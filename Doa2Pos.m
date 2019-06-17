function x0 = Doa2Pos(arrayPositions,alphas,betas,gammas, psi_xs,psi_ys)
%%
% output:
% x0 = [x, y, z]', the x-, y-, and z- coordinates
%
% input:
% arrayPosition= [x, y, z]', the x-, y-, and z- coordinates
% alphas = platform rotation angle about the x-axis
% betas = platform rotation angle about the y-axis
% gammas = platform rotation angle about the z-axis
% psi_x = direction of arrival
% psi_y = direction of arrival
%

% Directions of Arrival to Position
% Sang Min Han
% 07/10/2015

%%
totalSlowTimes= length(psi_ys);

%% Approach 1
% x0= zeros(3,totalSlowTimes);

%% Approach 2
A= zeros(2*totalSlowTimes,3);
b= zeros(2*totalSlowTimes,1);

for is= 1:totalSlowTimes
    %% Approach 1
    %     % adjust the direction of arrival from ura orientation
    %     R= RotationMatrix(alphas(is), betas(is), gammas(is));
    %     theta_x= pi/2 - psi_xs(is);
    %     theta_y= pi/2 - psi_ys(is);
    %     k= [cos(theta_x); cos(theta_y); 0];
    %     k(3)= -1*sqrt(1 - sum(k.^2)); % address z pointing direction
    %     k= R*k;
    %
    %     x= arrayPositions(:,is);
    %     % assume flat Earth
    %     rad= -1*x(3)/k(3);
    %     x0(:,is)= x + rad*k;
    
    %% Approach 2
    [n1, n2]= Doa2N( alphas(is), betas(is), gammas(is), psi_xs(is), psi_ys(is) );
    A(2*is - 1,:)= n1';
    A(2*is,:)= n2';
    b(2*is - 1)= dot(arrayPositions(:,is),n1);
    b(2*is)= dot(arrayPositions(:,is),n2);
end

%% Approach 1
% x0= mean(x0,2);

%% Approach 2
% solve the overdetermined system for source position
x0= A\b;

end

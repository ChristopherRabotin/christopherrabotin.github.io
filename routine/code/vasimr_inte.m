function [ x_dot ] = vasimr_inte( t, X )
%VASIMR_INTE the two body numerical integration function.

% X0 = [r v T angle mass]

r = norm(X(1:3));
body = Sun;

dry_mass = 5500;

shooting_angle = acosd(dot([X(1) X(2) X(3)], [1 0 0])/ (norm([X(1) X(2) X(3)]) * norm([1 0 0]) ));

T_vec = [X(7)*cosd(shooting_angle);X(7)*sind(shooting_angle);0]; % We are only looking at the velocity magnitude.
dv_T = (1/(X(8) + dry_mass)) * T_vec;

x_dot = [X(4);
         X(5);
         X(6);
         (-body.mu*X(1))/r^3 + dv_T(1);
         (-body.mu*X(2))/r^3 + dv_T(2);
         (-body.mu*X(3))/r^3 + dv_T(3);
         0; % Thrust does not change
         X(10); % Fuel mass change with the flow rate.
         0 % Step size does not change.
         0; % Mass flow rate.
         ];
end


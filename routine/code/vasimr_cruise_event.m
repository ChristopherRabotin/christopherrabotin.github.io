function [ value, isterminal, direction ] = vasimr_cruise_event( t, X )
% Locate the time when the radius magnitude we wanted to reach has been reached.

r_soi = 5.7723e+05;

tol = 2.1 * r_soi;

desired_r = [-187336535.314101; 131825974.058637; 0];

dRR = abs(norm(X(1:3)) - norm(desired_r));
fprintf('Distance to Mars orbit=%3.6f km\n', dRR)

if dRR < tol % We're within reach.
    value = -1;
else
    value = 1;
end
isterminal = 1;
direction = 0;

end


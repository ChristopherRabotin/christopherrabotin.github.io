function [  ] = vasimr( r, v, T, dt, Isp)
%VASIMR Propagate the provided r and v vectors using a maximum thrust of T
%and a given shooting angle (angle paramater). Thrust will occur until
%velocity vd is achieved. Another thrust will happen in order to match va
%on arrival. The input mass is needed to compute the velocity changes.
%Is also needed dt which is time to propagate in days.

%% Prop 1: burn to get on the transfer orbit.
% ==> REMEMBER TO SET THE DESIRED VELOCITY!
step = 0.02; % Step size between each computation.
time = 0:step:dt*3600*24;
mflow = - T / (Isp*9.81);
fuel_mass = 500;
X0 = [r v T fuel_mass step mflow];
disp('==== BURN 1 STARTED ====')

opts  = odeset('Events', @vasimr_out_event);
[~, ~, tE1, xE1, ~] = ode45(@vasimr_inte, time, X0, opts);

disp('==== BURN 1 COMPLETED ====')
tEh = tE1/3600;
b1v = norm(xE1(4:6));
fprintf('Duration: %5.3f seconds\n', tE1)
fprintf('Heliocentric velocity: %5.3f km/s\n', b1v)
fprintf('Heliocentric velocity: [%5.3f %5.3f %5.3f]km/s \n', xE1(4), xE1(5), xE1(6))
fprintf('Heliocentric position: [%5.3f %5.3f %5.3f]km\n', xE1(1), xE1(2), xE1(3))
fprintf('Remaining fuel: %5.3f kg\n', xE1(8))

%% Cruise to Mars SOI
% Note: we use the same integrator, just make sure you're not burning
% anything.
x1 = xE1(:);
x1(7) = 0; % Set Thrust to nil.
x1(10) = 0; % Set mass flow to nil.

step = 3600*24; % Step size between each computation.
time = 0:step:365.25*3600*24/2; % Cruise for up to 6 months.
disp('==== CRUISE STARTED ====')

opts  = odeset('Events', @vasimr_cruise_event);
[~, ~, tE2, xE2, ~] = ode45(@vasimr_inte, time, x1, opts);
% Odd issue with the velocity not being set. I hope I'm used ODE45
% correctly.
xE2b = xE2(:);
xE2b(4) = xE1(4);
xE2b(5) = xE1(5);
xE2b(6) = xE1(6);
xE2 = xE2b;

disp('==== CRUISE COMPLETED ====')
tEh = tE2/(3600*24);
b1v = norm(xE2(4:6));
fprintf('Duration: %5.3f days\n', tEh)
fprintf('Heliocentric velocity: %5.3f km/s (should not have changed)\n', b1v)
fprintf('Heliocentric position: [%5.3f %5.3f %5.3f]km\n', xE2(1), xE2(2), xE2(3))
fprintf('Remaining fuel: %5.3f kg (should not have changed)\n', xE2(8))

%% Slow down
% ==> REMEMBER TO SET THE DESIRED ARRIVAL VELOCITY!
x2 = xE2(:);
x2(7) = -T; % Set Thrust to a slow down burn.
x2(10) = mflow; % Set mass flow to nil.
step = 1; % Step size between each computation.
time = 0:step:1*3600*24;

disp('==== BURN 2 STARTED ====')

opts  = odeset('Events', @vasimr_out_event_approach);
[~, ~, tE3, xE3, ~] = ode45(@vasimr_inte, time, x2, opts);

disp('==== BURN 2 COMPLETED ====')

b1v = norm(xE3(4:6));
r_MSC = abs(norm(xE3(1:3)) - 229070000);
fprintf('Duration: %5.3f seconds\n', tE3)
fprintf('Heliocentric velocity: %5.3f km/s\n', b1v)
fprintf('Heliocentric velocity: [%5.3f %5.3f %5.3f]km/s \n', xE3(4), xE3(5), xE3(6))
fprintf('Heliocentric position: [%5.3f %5.3f %5.3f]km\n', xE3(1), xE3(2), xE3(3))
fprintf('Distance to Mars orbit: %5.3f km\n', r_MSC)
fprintf('Remaining fuel: %5.3f kg\n', xE3(8))
end


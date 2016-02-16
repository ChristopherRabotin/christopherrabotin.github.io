function [ value, isterminal, direction ] = vasimr_out_event(t, X)
% Locate the time when the velocity magnitude we wanted to reach has been reached.

desired_v = 28.2212;

v = abs(norm(X(4:6)));
dVR = abs(v - desired_v);
fprintf('v=%3.6f km/s (dV remaining=%3.6f km/s); fuel = %5.2f kg\n', v, dVR, X(8))
tol = 0.91; % Tolerance must be adapted all the time...

% Bizarre situation: if the velocity difference reaches what is desired,
% but the event is not triggered, the velocity then goes back up. No idea
% why. It also is evident that more steps in the integrator do not call the
% event more.
if dVR < tol % We're within reach.
    value = -1;
else
    value = 1;
end
isterminal = 1;
direction = 0;

end


function [ best_dv, best_angle, best_r1, best_r2, best_v1, best_v2 ] = opt_dv_lambert( earth_period, max_dt )
% opt_dv_lamber for a given earth period in days, compute the lowest delta
% V needed. For example, if earth period is 365.25, then Lambert's problem
% will be solved (with the parameters below) for every day and the minimum
% delta v changes will be reported for the year. Another example: if the
% lowest delta v is needed for a three month period, then the input
% argument should be 365.25/3. Note that the period will be rounded. The
% max_dt input paramater is the maximum duration of flight wanted.

%% Parameters
synodic_period = 2.135; % Used to know the number of variables to store.
earth_period = round(earth_period);
earth_angles = 0:(360/365.25):360*synodic_period;
earth_distance = 149640000; % km
earth_velocity = 29.7805; % km/s

mars_angles = 0:0.9850/synodic_period:360;
mars_distance = 229070000; % km
mars_velocity = 24.0698; % km/s

%% Computation
num_angles = length(earth_angles);
periods = ceil(365.25*synodic_period/earth_period);
step = num_angles/periods;
best_r1 = zeros(3, periods);
best_r2 = zeros(3, periods);
best_v1 = zeros(3, periods);
best_v2 = zeros(3, periods);
best_dv = zeros(1, periods);
best_angle = zeros(2, periods);

for period = 0:periods
    min_r1 = [NaN NaN NaN];
    min_r2 = [NaN NaN NaN];
    min_v1 = [NaN NaN NaN];
    min_v2 = [NaN NaN NaN];
    min_dv = inf;
    min_angle = [NaN NaN];
    for idx = floor(period*step) + 1:floor(min(period*(step+1) + 1, num_angles))
        
        ea = earth_angles(idx);
        ma = mars_angles(idx);
        
        evec = [earth_distance*cosd(ea) earth_distance*sind(ea) 0];
        
        mvec = [mars_distance*cosd(ma) mars_distance*sind(ma) 0];
        % Call Lambert function.
        [v1, v2, ~, flg] = lambert(evec, mvec, max_dt, 0, Sun.mu);
        % Check there was a solution.
        if flg < 0
            sprintf('[flg] no solution found for idx=%d', idx)
            continue
        end
        if isnan(norm(v1))
            sprintf('[v1] no solution found for idx=%d', idx)
            continue
        end
        if isnan(norm(v2))
            sprintf('[v2] no solution found for idx=%d', idx)
            continue
        end
        % Compute the delta Vs.
        dv1 = abs(norm(v1) - earth_velocity);
        dv2 = abs(mars_velocity - norm(v2));
        % Check if it's a new min.
        if dv1 + dv2 < min_dv
            % Yay!
            min_angle = [ea ma];
            min_dv = dv1 + dv2;
            min_r1 = evec;
            min_r2 = mvec;
            min_v1 = v1;
            min_v2 = v2;
        end
    end
    % Let's now save the minimums.
    best_dv(period + 1) = min_dv;
    best_angle(:, period + 1) = min_angle;
    best_r1(:, period + 1) = min_r1;
    best_r2(:, period + 1) = min_r2;
    best_v1(:, period + 1) = min_v1;
    best_v2(:, period + 1) = min_v2;
end

end
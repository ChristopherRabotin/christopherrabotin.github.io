function circ_plot(iea, ima, x1, y1)

figure
hold on
earth = 149640000;
mars = 229070000;
t = linspace(0,2*pi);plot(earth*cos(t),earth*sin(t), 'Color', 'b')
t = linspace(0,2*pi);plot(mars*cos(t),mars*sin(t), 'Color', 'r')
ylabel('Y position (km)')
xlabel('X position (km)')
plot(0, 0, 'y+', 'MarkerSize', 12)
plot(0, 0, 'yx', 'MarkerSize', 12)

r1 = [earth*cosd(iea) earth*sind(iea)];
r2 = [mars*cosd(ima) mars*sind(ima)];

plot(r1(1), r1(2), 'bo', 'MarkerSize', 12)
plot(r2(1), r2(2), 'ro', 'MarkerSize', 12)

plot(95380049.255, -115727254.886, 'g+', 'MarkerSize', 15)

plot(x1,y1, 'g+', 'MarkerSize', 15)

end
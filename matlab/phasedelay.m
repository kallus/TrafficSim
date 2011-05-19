c = 2;
lambda = 1;
T = 0.5;

figure(1);
clf;
axis([0 10 0 5]);
hold on;
xlabel('x_1 position');
ylabel('x_2 velocity');
title(sprintf('Car following phase portrait, \\lambda=%.2f c=%.2f T=%.2f',lambda,c,T));

starts = [2 10; 4 10; 6 10; 8 10;...
    0 0; 2 0; 4 0; 6 0; 8 0;...
    0 1; 0 3; 0 5; 0 7; 0 9];

for i = 1:29
    ts = linspace(0,10,1000);
    dt = diff(ts); dt = dt(1);
    %[x1, x2] = ginput(1);
    x1 = starts(i,1);
    x2 = starts(i,2);
    x1s = [x1];
    x2s = [x2];
    for t = ts
        old_x2 = x2s(end-min(round(T/dt), numel(x2s)-1));
        x2 = x2 + lambda * dt * (c - old_x2);
        x1 = x1 + dt * x2;
        x1s = [x1s x1];
        x2s = [x2s x2];
    end
    plot(x1s, x2s);
end
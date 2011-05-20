t = linspace(0,10,1000);
c = 3;
lambda = 1;
figure(1);
clf;
axis([0 10 0 10]);
hold on;
xlabel('x_1 position');
ylabel('x_2 velocity');
title(sprintf('Car following phase portrait, \\lambda=%.2f c=%.2f',lambda,c));
starts = [0 10; 1 10; 2 10; 3 10; 4 10; 5 10; 6 10; 7 10; 8 10; 9 10;...
    0 0; 1 0; 2 0; 3 0; 4 0; 5 0; 6 0; 7 0; 8 0; 9 0;...
    0 1; 0 2; 0 3; 0 4; 0 5; 0 6; 0 7; 0 8; 0 9];
for i = 1:29
    %[x1_0, x2_0] = ginput(1);
    x1_0 = starts(i,1);
    x2_0 = starts(i,2);
    B = x2_0 - c;
    A = x1_0 + B/lambda;
    x1 = c*t - exp(-lambda*t)*B/lambda + A;
    x2 = c + exp(-lambda*t)*B;
    plot(x1,x2);
end
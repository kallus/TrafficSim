XY = load('../avg_time.txt');
X = 0:60;
M = [];
Mm = [];
Mp = [];
for i = X
    Y = XY(XY==i, :);
    mea = mean(Y(:,2));
    dev = std(Y(:,2));
    M = [M mea];
    Mm = [Mm mea-dev];
    Mp = [Mp mea+dev];
end
figure(1);
clf;
hold on;
plot(XY(:,1), XY(:,2),'x', 'MarkerSize', 3);
plot(X, M, 'k');
plot(X, Mm, '--k');
plot(X, Mp, '--k');
legend('data', 'average', 'average-\sigma', 'average+\sigma', 'Location', 'NorthWest');
ylabel('Average time (s)');
xlabel('Number of random cars');
title('Average drive through time with different numbers of random cars');
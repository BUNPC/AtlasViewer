function ax = findClosestAxes(v)

s = dist3(v, [0,0,0]);

xyz(1,:) = [ s, 0, 0];
xyz(2,:) = [-s, 0, 0];
xyz(3,:) = [ 0, s, 0];
xyz(4,:) = [ 0,-s, 0];
xyz(5,:) = [ 0, 0, s];
xyz(6,:) = [ 0, 0,-s];

d(1) = dist3(v, xyz(1,:));
d(2) = dist3(v, xyz(2,:));
d(3) = dist3(v, xyz(3,:));
d(4) = dist3(v, xyz(4,:));
d(5) = dist3(v, xyz(5,:));
d(6) = dist3(v, xyz(6,:));

[~,i] = min(d);
ax = xyz(i,:);


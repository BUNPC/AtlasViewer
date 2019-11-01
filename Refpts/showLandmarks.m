function showLandmarks(nz,iz,rpa,lpa,cz,czo)

l1 = points_on_line(rpa, lpa, 1/100, 'all');
l2 = points_on_line(nz, iz, 1/100, 'all');
l3 = points_on_line(cz, czo, 1/100, 'all');

set(gca, {'xgrid', 'ygrid','zgrid'}, {'on','on','on'}); 
axis vis3d; 
axis equal
rotate3d
hold on

hl1 = plot3(l1(:,1), l1(:,2), l1(:,3), '.r'); 
hl2 = plot3(l2(:,1), l2(:,2), l2(:,3), '.g');
hl3 = plot3(l3(:,1), l3(:,2), l3(:,3), '.b');

hrpa = plot3(rpa(:,1), rpa(:,2), rpa(:,3), '.c', 'markersize',30);
hnz = plot3(nz(:,1), nz(:,2), nz(:,3), '.m', 'markersize',30);
hcz = plot3(cz(:,1), cz(:,2), cz(:,3), '.k', 'markersize',30);


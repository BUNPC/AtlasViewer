function [densitymean, densitymax, densitymin] = meshdensity(mesh)

densitymean=1;
densitymax=1;
densitymin=1;

if ~isstruct(mesh) 
    return;
end
if ~isfield(mesh,'faces') || ~isfield(mesh,'vertices') 
    return;
end

faces = mesh.faces;
vertices = mesh.vertices;
n=size(faces,1);
if n==0
    return;
end
nsample=round(n/10);
ifaces=ceil((n-1)*rand(1,nsample));
density=zeros(nsample,3);
for ii=1:nsample
    ivert = faces(ifaces(ii),:);
    density(ii,1) = dist3(vertices(ivert(1),:), vertices(ivert(2),:));
    density(ii,2) = dist3(vertices(ivert(1),:), vertices(ivert(3),:));
    density(ii,3) = dist3(vertices(ivert(2),:), vertices(ivert(3),:));
end
densitymean = mean(density(:));
densitymax = max(density(:));
densitymin = min(density(:));


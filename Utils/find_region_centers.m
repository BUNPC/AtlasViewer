%
% USAGE:
%
% region_centers = find_region_centers(region_vertices)
%

function region_centers = find_region_centers(region_vertices)

n=length(region_vertices);
region_centers=zeros(n,3);
for i=1:n
    vert=region_vertices{i};
    region_size=size(vert);
    region_size=region_size(1);
    if (region_size > 0)
        xmin=min(vert(:,1));
        xmax=max(vert(:,1));
        ymin=min(vert(:,2));
        ymax=max(vert(:,2));
        zmin=min(vert(:,3));
        zmax=max(vert(:,3));            

        region_centers(i,1)=round(xmin+((xmax-xmin)/2));
        region_centers(i,2)=round(ymin+((ymax-ymin)/2));
        region_centers(i,3)=round(zmin+((zmax-zmin)/2));
    end
end

    

function [v2, xoffset, yoffset, zoffset] = resizeVolume(v1)

dims0 = size(v1);

bbox = gen_bbox(v1);

xmin = min(bbox(:,1));
xmax = max(bbox(:,1));
ymin = min(bbox(:,2));
ymax = max(bbox(:,2));
zmin = min(bbox(:,3));
zmax = max(bbox(:,3));
xoffset = 1;
yoffset = 1;
zoffset = 1;

p = 20;
dims = dims0;
if xmin<p
    dims(1) = dims(1)+p;
    xoffset = p/2;
end 
if abs(xmax-dims0(1))<p
    dims(1) = dims(1)+p;
    xoffset = p;
end 
if ymin<p
    dims(2) = dims(2)+p;
    yoffset = p/2;
end 
if abs(ymax-dims0(2))<p
    dims(2) = dims(2)+p;
    yoffset = p;
end 
if zmin<p
    dims(3) = dims(3)+p;
    zoffset = p/2;
end 
if abs(zmax-dims0(3))<p
    dims(3) = dims(3)+p;
    zoffset = p;
end

v2 = zeros(dims(1), dims(2), dims(3));

if all(dims==dims0)
    v2 = v1;
    return;
end

v2(xoffset:xoffset+dims0(1)-1, yoffset:yoffset+dims0(2)-1, zoffset:zoffset+dims0(3)-1) = v1;



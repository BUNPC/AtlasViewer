function resize_axes(hObject, optpos, landmarks)

if nargin==2 || isempty(landmarks)
    landmarks.pos = [];
end
p = [optpos; landmarks.pos];

if isempty(p)
    return;
end

xmin = min(p(:,1));
xmax = max(p(:,1));
ymin = min(p(:,2));
ymax = max(p(:,2));
zmin = min(p(:,3));
zmax = max(p(:,3));
nopt_x = length(unique(p(:,1)));
nopt_y = length(unique(p(:,2)));
nopt_z = length(unique(p(:,3)));
if length(unique(p(:,3)))==1
    pz = 1;
else
    pz = (zmax-zmin)/nopt_z;
end
if length(unique(p(:,2)))==1
    py = 1;
else
    py = (ymax-ymin)/nopt_y;
end
if length(unique(p(:,1)))==1
    px = 1;
else
    px = (xmax-xmin)/nopt_x;
end
set(hObject, 'xlim',[xmin-px xmax+px]);
set(hObject, 'ylim',[ymin-py ymax+py]);
set(hObject, 'zlim',[zmin-pz zmax+pz]);

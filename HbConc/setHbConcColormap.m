function hbconc = setHbConcColormap(hbconc, hAxes)

hclim = hbconc.handles.editColormapThreshold;

if ~isempty(hAxes)
    axes(hAxes);
else
    %colorbar off;
    return;
end

val = get(hbconc.handles.popupmenuImageDisplay,'value');
if val<hbconc.menuoffset+1 | val>hbconc.menuoffset+2
    return;
end

val = val-hbconc.menuoffset;

% Get colopmap editbox input and check it for errors 
climstr = get(hclim,'string');
if ~isnumber(climstr)
    set(hclim,'string',sprintf('%0.2g %0.2g',hbconc.cmThreshold(val,1), hbconc.cmThreshold(val,2)));
    return;
end
clim = str2num(climstr);
if length(clim)~=2
    set(hclim,'string',sprintf('%0.2g %0.2g',hbconc.cmThreshold(val,1), hbconc.cmThreshold(val,2)));
    return;
end
if clim(1)>=clim(2)
    set(hclim,'string',sprintf('%0.2g %0.2g',hbconc.cmThreshold(val,1), hbconc.cmThreshold(val,2)));
    return;
end

hbconc.cmThreshold(val,:) = clim;
set(hclim,'string',sprintf('%0.2g %0.2g',hbconc.cmThreshold(val,1), hbconc.cmThreshold(val,2)));

% Set colormap values 
colorbar;
n = 1000;
cm = jet(n);
cmRange = clim(2) - clim(1);
k(1) = floor((abs(clim(1))* n) / cmRange)-1;
k(2) = floor((abs(clim(1))* n) / cmRange);
k(3) = floor((abs(clim(1))* n) / cmRange)+1;
for ii=1:length(k)
    if k(ii)<1
        k(ii)=1;
    elseif k(ii)>n
        k(ii)=n;
    end
    cm(k(ii),:) = hbconc.colormin;
end
colormap(cm);
caxis(clim);

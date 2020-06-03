function fwmodel = setSensitivityColormap(fwmodel, hAxes)

hclim = fwmodel.handles.editColormapThreshold;

if ~isempty(hAxes)
    axes(hAxes);
else
    colorbar off;
    return;
end

% Get colopmap editbox input and check it for errors
climstr = get(hclim,'string');
if ~AVUtils.isnumber(climstr)
    set(hclim,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1),fwmodel.cmThreshold(2)));
    return;
end
clim = str2num(climstr);
if length(clim)~=2
    set(hclim,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1),fwmodel.cmThreshold(2)));
    return;
end
if clim(1)>=clim(2)
    set(hclim,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1),fwmodel.cmThreshold(2)));
    return;
end

fwmodel.cmThreshold = clim;
set(hclim,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1),fwmodel.cmThreshold(2)));

% Set colormap values 
colorbar;
cm = jet(100);
cm(1,:) = fwmodel.colormin;
colormap(cm);
caxis(fwmodel.cmThreshold);

function menuItemViewAxes_Callback(hObject, eventdata, handles)
global atlasViewer

axesv = atlasViewer.axesv; 
refpts = atlasViewer.refpts;

if leftRightFlipped(refpts)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

type = get(hObject,'type');
label = get(hObject,'label');
if strcmp(type, 'uimenu')
    checked_propname = 'checked';
    ia = 1;
elseif strcmp(type, 'uicontrol')
    checked_propname = 'value';
    ia = 2;
end

hAxes = axesv(ia).handles.axesSurfDisplay;
hOrigin = getappdata(hAxes, 'hOrigin');

labels = {'XYZ','RAS'};
if strcmp(label, 'XYZ')
    idx = 1;
elseif strcmp(label, 'RAS')
    idx = 2;
elseif strcmp(label, 'XYZ and RAS')
    idx = [1,2];
end

onoff = '';
for ii=1:length(idx)
    if ~AVUtils.ishandles(hOrigin(idx(ii),:))
        continue;
    end
    if strcmp(get(hOrigin(idx(ii),:), 'visible'), 'off')
        if ia==1
            onoff = 'on';
        elseif ia==2
            onoff = 1;
        end
    elseif strcmp(get(hOrigin(idx(ii),:), 'visible'), 'on')
        if ia==1
            onoff = 'off';
        elseif ia==2
            onoff = 0;
        end
    end
    eval( sprintf('set(handles.menuItemViewAxes%s, checked_propname, onoff);', labels{idx(ii)}) );
    eval( sprintf('viewAxes%s(hAxes, axes_order, [], ''donotredraw'');', labels{idx(ii)}) );
end
if isempty(onoff)
    return;
end
set(hObject, checked_propname, onoff);

function fwmodel = enableFwmodelDisplay(fwmodel, val)

if val==0
    val='off';
elseif val==1
    val='on';
end

set(fwmodel.handles.menuItemGetSensitivityatMNICoordinates,'enable',val);

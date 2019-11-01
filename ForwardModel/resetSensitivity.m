function fwmodel = resetSensitivity(fwmodel, probe, dirnameSubj)

% Turn off controls related to projecting fwmodel  onto pialsurf.
% We'll  turn   them back on if probe registration     is successful
if ishandles(fwmodel.handles.surf)
    delete(fwmodel.handles.surf);
    fwmodel.handles.surf = [];
end


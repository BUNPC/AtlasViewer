function fwmodel = resetFwmodel(fwmodel, headvol)

if ~exist('headvol','var')
    headvol = initHeadvol();
end

% Turn off controls related to projecting sensitivity  onto pialsurf.
% We'll  turn   them back on if probe registration     is successful
fwmodel = enableDisableMCoutputGraphics(fwmodel, 'off');
fwmodel = enableFwmodelDisplay(fwmodel, 'off');
if ishandles(fwmodel.handles.surf)
    delete(fwmodel.handles.surf);
    fwmodel.handles.surf = [];
end

fwmodel = setSensitivityColormap(fwmodel, []);

if ~headvol.isempty(headvol)
    fwmodel.headvol = headvol;
    fwmodel.headvol.orientationOrig = fwmodel.headvol.orientation;
    fwmodel.projVoltoMesh_brain = '';
    fwmodel.projVoltoMesh_scalp = '';    
end


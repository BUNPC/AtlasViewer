function labelssurf = resetLabelssurf(labelssurf)

hLabelsSurf  = labelssurf.handles;
mesh         = labelssurf.mesh;
vertices     = labelssurf.mesh.vertices;
idxL         = labelssurf.idxL;
namesL       = labelssurf.names;
colormaps    = labelssurf.colormaps;
idxCm        = labelssurf.colormapsIdx;

if ~ishandles(hLabelsSurf)
    return;
end

cm = colormaps(idxCm).col;
set(hLabelsSurf,'faceVertexCData',cm(idxL,:));

% Restore all faces transparency to the most common alpha; 
% that is, turn off all highlighted faces from previous 
% probe cortex projections. 
alpha0 = get(hLabelsSurf,'faceVertexAlphaData');
alpha = alpha0 * 100;
x=min(alpha):max(alpha);
[foo idx] = max(histc(sort(alpha),x));
alpha = x(idx)/100;
set(hLabelsSurf,'faceVertexAlphaData',alpha*ones(size(mesh.faces,1),1));

labelssurf.iFaces = [];



function hbconc = resetHbConc(hbconc)

if ishandles(hbconc.handles.HbO)
    delete(hbconc.handles.HbO);
    hbconc.handles.HbO = [];
end
if ishandles(hbconc.handles.HbR)
    delete(hbconc.handles.HbR);
    hbconc.handles.HbR = [];
end
hbconc = setHbConcColormap(hbconc, []);
hbconc.mesh = initMesh();

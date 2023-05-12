function hbconc = showHbConcDisplay(hbconc, hAxes, valHbO, valHbR)
if isempty(hAxes)
    hAxes = gca;
end
if strcmp(valHbO,'on') || strcmp(valHbR,'on')
    if strcmp(valHbO,'on')
        hImg = hbconc.handles.HbO;
    else
        hImg = hbconc.handles.HbR;
    end    
    val = 'on';
else
    hImg = [];
    val = 'off';
end
if ~isempty(hImg)
    img = hImg.FaceVertexCData;
else
    img = [];
end
hbconc = setHbConcColormap(hbconc, hAxes, img);
set(hbconc.handles.HbO,'visible',valHbO);
set(hbconc.handles.HbR,'visible',valHbR);
setImageDisplay_EmptyImage(hImg, val);


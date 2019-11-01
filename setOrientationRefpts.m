function [headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc] = ...
    setOrientationRefpts(refpts, headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc)

if refpts.isempty(refpts)
    return;
end

if isempty(refpts.orientation)
    [nz,iz,rpa,lpa,cz] = getLandmarks(refpts);
    [refpts.orientation, refpts.center]  = getOrientation(nz,iz,rpa,lpa,cz);
end 

headvol                = saveHeadvolOrient(headvol, refpts);

headsurf.orientation   = refpts.orientation;
headsurf.center        = refpts.center;

pialsurf.orientation   = refpts.orientation;
pialsurf.center        = refpts.center;

labelssurf.orientation = refpts.orientation;
labelssurf.center      = refpts.center;

if isempty(probe.orientation)
    probe.orientation      = refpts.orientation;
    probe.center           = refpts.center;
end

fwmodel.orientation    = refpts.orientation;
fwmodel.center         = refpts.center;

imgrecon.orientation   = refpts.orientation;
imgrecon.center        = refpts.center;

hbconc.orientation   = refpts.orientation;
hbconc.center        = refpts.center;

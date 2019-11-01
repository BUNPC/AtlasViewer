function [refpts, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc] = ...
     setOrientationHeadvol(headvol, refpts, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc)

if headvol.isempty(headvol)
    return;
end
if isempty(headvol.orientation)
    return;
end

refpts.orientation     = headvol.orientation;
refpts.center          = headvol.center;

headsurf.orientation   = headvol.orientation;
headsurf.center        = headvol.center;

pialsurf.orientation   = headvol.orientation;
pialsurf.center        = headvol.center;

labelssurf.orientation = headvol.orientation;
labelssurf.center      = headvol.center;

if isempty(probe.orientation)
    probe.orientation      = headvol.orientation;
    probe.center           = headvol.center;
end

fwmodel.orientation    = headvol.orientation;
fwmodel.center         = headvol.center;

imgrecon.orientation   = headvol.orientation;
imgrecon.center        = headvol.center;



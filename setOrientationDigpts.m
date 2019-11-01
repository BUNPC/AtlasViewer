function [refpts, headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc] = ...
    setOrientationDigpts(digpts, refpts, headvol, headsurf, pialsurf, labelssurf, probe, fwmodel, imgrecon, hbconc)

if isempty(digpts.orientation)
    return;
end

refpts.orientation     = digpts.orientation;
refpts.center          = digpts.center;

headvol                = saveHeadvolOrient(headvol, digpts);

headsurf.orientation   = digpts.orientation;
headsurf.center        = digpts.center;

pialsurf.orientation   = digpts.orientation;
pialsurf.center        = digpts.center;

labelssurf.orientation = digpts.orientation;
labelssurf.center      = digpts.center;

probe.orientation      = digpts.orientation;
probe.center           = digpts.center;

fwmodel.orientation    = digpts.orientation;
fwmodel.center         = digpts.center;
fwmodel.headvol.orientation    = digpts.orientation;

imgrecon.orientation   = digpts.orientation;
imgrecon.center        = digpts.center;

hbconc.orientation   = refpts.orientation;
hbconc.center        = refpts.center;




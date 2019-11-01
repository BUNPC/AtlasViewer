function probe = resetProbe(probe)

% dynamic handles
if ishandles(probe.handles.hOptodes)
   delete(probe.handles.hOptodes);
end
if ishandles(probe.handles.hOptodesCircles)
   delete(probe.handles.hOptodesCircles);
end
if ishandles(probe.handles.hProjectionPts)
   delete(probe.handles.hProjectionPts);
end
if ishandles(probe.handles.hMeasList)
   delete(probe.handles.hMeasList);
end
if ishandles(probe.handles.hSprings)
   delete(probe.handles.hSprings);
end
if ishandles(probe.handles.hProjectionRays)
   delete(probe.handles.hProjectionRays);
end
for ii=1:length(probe.handles.hProjectionTbl)
    if ishandle(probe.handles.hProjectionTbl(ii))
        if probe.handles.hProjectionTbl(ii)>0
            delete(probe.handles.hProjectionTbl(ii));
            probe.handles.hProjectionTbl(ii)=-1;
        end
    end
end


% static handles
set(probe.handles.checkboxHideProbe,'enable','off');
set(probe.handles.checkboxHideSprings,'enable','off');
set(probe.handles.checkboxHideDummyOpts,'enable','off');
set(probe.handles.checkboxHideMeasList,'enable','off');
set(probe.handles.pushbuttonRegisterProbeToSurface,'enable','off');


probe.hideProbe         = get(probe.handles.checkboxHideProbe,'value');
probe.hideSprings       = get(probe.handles.checkboxHideSprings,'value');
probe.hideDummyOpts     = get(probe.handles.checkboxHideDummyOpts,'value');
probe.hideMeasList      = get(probe.handles.checkboxHideMeasList,'value');
probe.handles.hOptodes            = [];
probe.handles.hOptodesCircles     = [];
probe.handles.hMeasList           = [];
probe.handles.hOptodesCortex      = [];
probe.handles.hOptToLabelsProjTbl = [];
probe.handles.hSprings            = [];
probe.handles.hSDgui              = [];
probe.handles.hProjectionRays     = [];
probe.srcpos                      = [];
probe.detpos                      = [];
probe.srcmap                      = [];
probe.detmap                      = [];
probe.optpos                      = [];
probe.optpos_reg                  = [];
probe.nsrc                        = 0;
probe.ndet                        = 0;
probe.nopt                        = 0;
probe.noptorig                    = 0;
probe.mlmp                        = [];
probe.ptsProj_cortex              = [];
probe.ptsProj_cortex_mni          = [];
probe.ml                = [];
probe.sl                = [];
probe.al                = [];
probe.hOptodesIdx       = 1;
probe.posprobe_data     = [];



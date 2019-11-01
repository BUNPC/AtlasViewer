function probe = initProbeProjection(probe)

% dynamic handles
for ii=1:length(probe.handles.hProjectionTbl)
    if ishandle(probe.handles.hProjectionTbl(ii))
        if probe.handles.hProjectionTbl(ii)>0
            delete(probe.handles.hProjectionTbl(ii));
            probe.handles.hProjectionTbl(ii)=-1;
        end
    end
end

if ishandles(probe.handles.hProjectionPts)
   delete(probe.handles.hProjectionPts);
   probe.handles.hProjectionPts=[];
end
if ishandles(probe.handles.hProjectionRays)
   delete(probe.handles.hProjectionRays);
   probe.handles.hProjectionRays=[];
end


% static handles
if isempty(probe.optpos_reg)
    set(probe.handles.menuItemProbeToCortex, 'enable','off');
    set(probe.handles.menuItemOverlayHbConc, 'enable','off');
else
    set(probe.handles.menuItemProbeToCortex, 'enable','on');
    set(probe.handles.menuItemOverlayHbConc, 'enable','on');    
end

probe.ptsProj_cortex = [];
probe.ptsProj_cortex_mni = [];


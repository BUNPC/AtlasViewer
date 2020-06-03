function probe = resetProbeGui(probe)

hSprings = probe.handles.hSprings;
hOptodes = probe.handles.hOptodes;
hOptodesCircles = probe.handles.hOptodesCircles;
hMeasList = probe.handles.hMeasList;
hProjectionPts = probe.handles.hProjectionPts;
hProjectionRays = probe.handles.hProjectionRays;

if AVUtils.ishandles(hOptodes)
   delete(hOptodes);
end
if AVUtils.ishandles(hOptodesCircles)
   delete(hOptodesCircles);
end
if AVUtils.ishandles(hProjectionPts)
   delete(hProjectionPts);
end
if AVUtils.ishandles(hMeasList)
   delete(hMeasList);
end
if AVUtils.ishandles(hSprings)
   delete(hSprings);
end  
if AVUtils.ishandles(probe.handles.hProjectionRays)
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


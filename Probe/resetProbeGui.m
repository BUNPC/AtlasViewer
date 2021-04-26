function probe = resetProbeGui(probe)

hSprings = probe.handles.hSprings;
hOptodes = probe.handles.labels;
hOptodesCircles = probe.handles.circles;
hMeasList = probe.handles.hMeasList;
hProjectionPts = probe.handles.hProjectionPts;
hRefpts = probe.handles.hRefpts;

if ishandles(hOptodes)
   delete(hOptodes);
end
if ishandles(hOptodesCircles)
   delete(hOptodesCircles);
end
if ishandles(hProjectionPts)
   delete(hProjectionPts);
end
if ishandles(hMeasList)
   delete(hMeasList);
end
if ishandles(hSprings)
   delete(hSprings);
end
if ishandles(hRefpts)
   delete(hRefpts);
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


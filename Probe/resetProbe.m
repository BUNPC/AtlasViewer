function probe = resetProbe(probe)

if nargin==0 || isempty(probe)
    probe = initProbe(handles);
end

% dynamic handles
if ishandles(probe.handles.labels)
   delete(probe.handles.labels);
end
if ishandles(probe.handles.circles)
   delete(probe.handles.circles);
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



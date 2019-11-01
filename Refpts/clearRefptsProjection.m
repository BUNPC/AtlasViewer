function refpts = clearRefptsProjection(refpts)

if ishandles(refpts.handles.hCortexProjection)
    delete(refpts.handles.hCortexProjection);
    refpts.handles.hCortexProjection = [];  
end
    
if ishandles(refpts.handles.hProjectionRays)
    delete(refpts.handles.hProjectionRays);
    refpts.handles.hProjectionRays = [];  
end


function refpts = clearRefptsProjection(refpts)

if AVUtils.ishandles(refpts.handles.hCortexProjection)
    delete(refpts.handles.hCortexProjection);
    refpts.handles.hCortexProjection = [];  
end
    
if AVUtils.ishandles(refpts.handles.hProjectionRays)
    delete(refpts.handles.hProjectionRays);
    refpts.handles.hProjectionRays = [];  
end


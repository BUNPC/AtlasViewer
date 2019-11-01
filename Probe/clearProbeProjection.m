function probe = clearProbeProjection(probe, iTbl)

if ~exist('iTbl','var') | isempty(iTbl)
    iTbl = [1:length(probe.handles.hProjectionTbl)];
end

if ishandles(probe.handles.hProjectionRays)
    delete(probe.handles.hProjectionRays);
    probe.handles.hProjectionRays = [];
end

for ii=iTbl
    if ishandle(probe.handles.hProjectionTbl(ii))
        if probe.handles.hProjectionTbl(ii)>0
            delete(probe.handles.hProjectionTbl(ii));
            probe.handles.hProjectionTbl(ii)=-1;
        end
    end
end

if ishandles(probe.handles.hProjectionPts)
    delete(probe.handles.hProjectionPts);
    probe.handles.hProjectionPts = [];
end

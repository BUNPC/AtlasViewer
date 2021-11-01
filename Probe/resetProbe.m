function probe = resetProbe(probe, dirname, handles)

if nargin==0 || isempty(probe)
    probe = initProbe;
end
if ~exist('dirname', 'var')
    dirname = pwd;
end
dirname = filesepStandard(dirname);

dirs = dir([dirname, '*']);
for ii = 1:length(dirs)
    if ~dirs(ii).isdir
        continue;
    end
    if strcmp(dirs(ii).name, '.')
        continue;
    end
    if strcmp(dirs(ii).name, '..')
        continue;
    end
    resetProbe(probe, [dirname, dirs(ii).name], handles);
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
for ii=1:length(probe.handles.hProjectionTbl)
    if ishandle(probe.handles.hProjectionTbl(ii))
        if probe.handles.hProjectionTbl(ii)>0
            delete(probe.handles.hProjectionTbl(ii));
            probe.handles.hProjectionTbl(ii)=-1;
        end
    end
end

probe = initProbe(handles);




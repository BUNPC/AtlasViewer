function fs2viewer = getFs2Viewer(fs2viewer, dirname)

if isempty(dirname)
    return;
end

if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end

if ~isempty(fs2viewer.hseg.filename)
    fs2viewer.hseg.volume = MRIread(fs2viewer.hseg.filename);
    [p,f,~] = fileparts(fs2viewer.hseg.filename);
    fs2viewer.hseg.orientation = getOrientationFromMriHdr(fs2viewer.hseg.volume);
    fd = fopen([p, '/', f, '_tiss_type.txt']);
    l  = 0;
    ii = 1;
    if fd>0
        while 1
            l = fgetl(fd);
            if all(l == -1)
                break;
            end
            fs2viewer.hseg.tiss_type{ii} = l;
            ii=ii+1;
        end
        fclose(fd);
    end
end

%{
if (exist([dirname, 'mri'],'dir') && ~exist([dirname, 'antomical'],'dir'))
    set(fs2viewer.handles.menuItemFs2Viewer,'enable','on');
else
    set(fs2viewer.handles.menuItemFs2Viewer,'enable','off');
end
%}

if isempty(fs2viewer.pathname)
    fs2viewer.pathname = dirname;
end


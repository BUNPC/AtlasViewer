function files2 = findUniqueProbeFiles(files)
files2 = [];
for ii = 1:length(files)
    [~, ~, ext] = fileparts(files(ii).name);
    switch(lower(ext))
        case '.sd'
            data = load(files(ii).name, '-mat');
            dotnirs(ii) = NirsClass(data.SD);
        case '.nirs'
            dotnirs(ii) = NirsClass(files(ii).name);
        case '.snirf'
            data = SnirfClass(files(ii).name);
            dotnirs(ii) = NirsClass(data);
    end
    if isUnique(dotnirs)
        fprintf('Adding  "%s"  to set of unique probe files in this group folder\n', files(ii).name);
        files2 = [files2, files(ii)];         %#ok<*AGROW>
    else
        fprintf('Discarding redundant probe file "%s"\n', files(ii).name);
    end
end



% -------------------------------------------------
function b = isUnique(dotnirs)
b = false;
for ii = 1:length(dotnirs)-1
    if dotnirs(end).ProbeEqual(dotnirs(ii))
        return
    end
end
b = true;



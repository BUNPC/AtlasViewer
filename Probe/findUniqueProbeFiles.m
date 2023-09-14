function files2 = findUniqueProbeFiles(files, probe_digpts, probe_data)
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
    
    if ~dotnirs(ii).IsProbeValid()
        fprintf('Discarding invalid probe file "%s"\n', files(ii).name);
    elseif isUnique(dotnirs) && compatibleProbes(dotnirs, probe_digpts) && compatibleProbes(dotnirs, probe_data)
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
    if dotnirs(end).ProbeSimilar(dotnirs(ii))
        return
    end
end
b = true;



% -------------------------------------------------
function b = compatibleProbes(dotnirs, probe)
b = true;
if isempty(probe)
    return;
end
if isempty(dotnirs)
    return;
end
probe1 = extractProbe(probe);
probe2 = extractProbe(dotnirs);
if probe1.isempty(probe1)
    return;
end
if probe2.isempty(probe2)
    return;
end
if size(probe1.srcpos,1) ~= size(probe2.srcpos,1)
    return;
end
if size(probe1.detpos,1) ~= size(probe2.detpos,1)
    return;
end

% In comparing meas list compatibility, order does not matter
probe1.ml = sort(probe1.ml);
probe2.ml = sort(probe2.ml);
if ~isempty(probe1.ml) && ~isempty(probe2.ml)
    if size(probe1.ml,1) ~= size(probe2.ml,1)
        return;
    end
    if ~all(probe1.ml(:) == probe2.ml(:))
        return;
    end
else
    return;
end
b = false;


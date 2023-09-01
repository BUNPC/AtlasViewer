function files = findUnique(files)

for ii = 1:length(files)
    [~, ~, ext] = fileparts(files(ii).name);
    switch(lower(ext))
        case '.sd'
            data = load(files(ii).name, '-mat');
            SD = data.SD;
        case '.nirs'
            data = load(files(ii).name, '-mat');
            SD = data.SD;
        case '.snirf'
            data = SnirfClass(files(ii).name);
            SD = NirsClass(data);
    end
end

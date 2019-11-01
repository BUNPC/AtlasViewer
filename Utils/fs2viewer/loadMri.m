function layer = loadMri(layer)

if isempty(layer)
    return;
end
if isempty(layer.filename)
    return;
end
if layer.isvolume && ~isempty(layer.volume.vol)
    return;
end

% Get mri volume 
mri = MRIread(layer.filename);

% Get tissue types associated with the mri volume if they exist
k = find(layer.filename=='.');
if ~isempty(k(end))
    filename_img_tiss = [layer.filename(1:k(end)-1), '_tiss_type.txt'];
    if exist(filename_img_tiss,'file')
        ii = 1;
        fid = fopen(filename_img_tiss,'r');
        while 1
            line = fgetl(fid);
            if line==-1
                break;
            end
            layer.tiss_type{ii} = line;
            ii=ii+1;
        end
        fclose(fid);
    end
end

[layer.orientation, layer.vol2surf] = getOrientationFromMriHdr(mri);

fields = fieldnames(mri);
for ii=1:length(fields)
    eval(sprintf('layer.volume.%s = mri.%s;', fields{ii}, fields{ii}));
end


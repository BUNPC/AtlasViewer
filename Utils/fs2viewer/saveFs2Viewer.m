function saveFs2Viewer(fs2viewer)

if isempty(fs2viewer.hseg.volume)
    return;
end
if exist(fs2viewer.hseg.filename, 'file')
    return;
end

dirnameVol = fs2viewer.mripaths.volumes;

mri        = fs2viewer.hseg.volume;
filename   = fs2viewer.hseg.filename;
tiss_type  = fs2viewer.hseg.tiss_type;

MRIwrite(mri, filename);
save_tiss_type([dirnameVol, 'hseg_tiss_type.txt'], tiss_type);




% Copy head volume if it exists to head.nii for purposes of registration
% with MNI reference volume.
if ~isempty(fs2viewer.layers.head.filename)
    mri = MRIread(fs2viewer.layers.head.filename);
    datatype = mri_datatype(mri);
    MRIwrite(mri, [fs2viewer.pathname, 'head.nii'], datatype);
    if exist([fs2viewer.pathname, 'head.nii'], 'file')
        gzip([fs2viewer.pathname, 'head.nii']);
        if exist([fs2viewer.pathname, 'head.nii.gz'], 'file')
            delete([fs2viewer.pathname, 'head.nii']);
        end
    end
end


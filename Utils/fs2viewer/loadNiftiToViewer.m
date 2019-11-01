function fs2viewer = loadNiftiToViewer(fs2viewer, nii, type)

if isempty(nii)
    return;
end

if ischar(nii)
    nii = load_untouch_nii(nii);
end

switch(type)
    case 'hseg'
        fs2viewer.hseg.vol        = nii.img;
        fs2viewer.hseg.nifti_hdr  = nii.hdr;
        fs2viewer.hseg.filetype   = nii.filetype;
        fs2viewer.hseg.fileprefix = nii.fileprefix;
        fs2viewer.hseg.filename   = [nii.fileprefix, '.nii'];
        fs2viewer.hseg.machine    = nii.machine;
        fs2viewer.hseg.ext        = nii.ext;
        fs2viewer.hseg.untouch    = nii.untouch;
    otherwise
        eval(sprintf('fs2viewer.layers.%s.vol        = nii.img;', type));
        eval(sprintf('fs2viewer.layers.%s.nifti_hdr  = nii.hdr;', type));
        eval(sprintf('fs2viewer.layers.%s.filetype   = nii.filetype;', type));
        eval(sprintf('fs2viewer.layers.%s.fileprefix = nii.fileprefix;', type));
        eval(sprintf('fs2viewer.layers.%s.filename   = [nii.fileprefix, ''.nii''];', type));
        eval(sprintf('fs2viewer.layers.%s.machine    = nii.machine;', type));
        eval(sprintf('fs2viewer.layers.%s.ext        = nii.ext;', type));
        eval(sprintf('fs2viewer.layers.%s.untouch    = nii.untouch;', type));
end
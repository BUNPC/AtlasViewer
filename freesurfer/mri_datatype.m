function datatype = mri_datatype(fname0)

% Get datatype of the volume data from the Freesurfer mri header 

datatype = '';

mri = [];
if isstruct(fname0)
    mri = fname0;
    fname0 = mri.fspec;
end

% Check if fname0 is a compressed file. If compress uncompress it and then
% process that.
fname = '';
[p,f,ext] = fileparts(fname0);
if strcmp(ext,'.gz')    
    fname = [p,'/',f];
    gunzip(fname0);
elseif strcmp(ext,'.mgz')
    fname = [p,'/',f,'.mgh'];
    gunzip(fname0);
    movefile([p,'/',f], fname);
else
    fname = fname0;
end

% Load mri if it wasn't already passed as an argument 
if isempty(mri)
    mri = MRIread(fname);
end

% Get file number of bytes per data element, if data is signed/unsigned and if it is integers or reals
file = dir(fname);
bytes_per_elem = round(file.bytes / mri.nvoxels);
signed = min(mri.vol) < 0;
integer = isintegerarr(mri.vol);

% Decide data type based on bytes-per-data-element, signed/unsigned and
% integers/reals
switch(bytes_per_elem)
    case 1
        datatype = 'uchar';
    case 2
        if signed 
            datatype = 'short';
        else
            datatype = 'ushort';
        end
    case 4
        if integer
            if signed 
                datatype = 'int';
            else
                datatype = 'uint';
            end
        else
            datatype = 'float';
        end
    case 8
        datatype = 'double';        
end


% If fname is a newly created file, then delete it now that it's served
% it's purpose.
if ~pathscompare(fname0,fname)
    delete(fname);
end


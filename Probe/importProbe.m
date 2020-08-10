function probe = importProbe(probe, filename, digpts)

[pname, fname, ext] = fileparts(filename);
pname = filesepStandard(pname);
switch lower(ext)
    case '.txt'

        probe.optpos   = load([pname, fname, ext], '-ascii');
        probe.nopt     = size(probe.optpos,1);
        probe.noptorig = size(probe.optpos,1);

    case {'.sd','.nirs'}

        filedata = load([pname, fname, ext], '-mat');
        probe = loadSD(probe,filedata.SD);
        
end
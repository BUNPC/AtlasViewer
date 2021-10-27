function probe = importProbe(probe, filename, headsurf, refpts)
if ~exist('headsurf','var')
    headsurf = [];
end
if ~exist('refpts','var')
    refpts = [];
end

[pname, fname, ext] = fileparts(filename);
pname = filesepStandard(pname);
switch lower(ext)
    case '.txt'
        probe = loadProbeFormTextFile(probe, [pname, fname, ext]);

    case {'.sd','.nirs'}

        filedata = load([pname, fname, ext], '-mat');
        probe = loadSD(probe, filedata.SD);

    case {'.snirf'}

        snirf = SnirfClass([pname, fname, ext]);
        SD = snirf.GetSDG();
        SD.MeasList = snirf.GetMeasList();
        probe = loadSD(probe, SD);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3. Preregister
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe = preRegister(probe, headsurf, refpts);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4. Check if registration data exists only if data from SD data was loaded. 
% If it was but probe is neither registered to head nor has registration 
% data, then offer to add it manually
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe = checkRegistrationData(pname, probe, headsurf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 5. Save new probe
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
probe.save(probe);





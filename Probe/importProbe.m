function probe = importProbe(probe, filename, headsurf, refpts, handles)
if ~exist('handles','var')
    handles = [];
end
dirname = probe.pathname;
resetProbe(probe, dirname, handles);
probe = initProbe(handles);
[~, ~, ext] = fileparts(filename);
if strcmpi(ext, '.SD')
    filedata = load(filename, '-mat');
    probe = loadSD(probe, filedata.SD);
elseif strcmpi(ext, '.snirf')
    s = SnirfClass(filename);
    n = NirsClass(s);
    probe = convertSD2probe(n.SD, handles);
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
probe = checkRegistrationData(dirname, probe, headsurf, refpts);

% Generate measurement list mid points in 3D if #D optodes exist
probe = checkMeasList(probe);



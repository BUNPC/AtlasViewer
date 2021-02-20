function probe = importProbe(probe, filename, headsurf, refpts)
global SD

SD = [];
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
        if isPreRegisteredProbe(probe, headsurf)
            probe.optpos_reg = probe.optpos;
        end

    case {'.sd','.nirs'}

        filedata = load([pname, fname, ext], '-mat');
        SD0 = filedata.SD;

    case {'.snirf'}

        snirf = SnirfClass([pname, fname, ext]);
        SD0 = snirf.GetSDG();
        SD0.MeasList = snirf.GetMeasList();
end

if isempty(SD0)
    return;
end

probe = loadSD(probe, SD0);
probe = preRegister(probe, headsurf, refpts);
sd_data_Init(SD0);
if ~probeHasSpringRegistrationInfo(SD)
    q = MenuBox('Probe does not contain enough data to register it to the head. Do you want to open probe in SDgui to add registration data?', {'Yes','No'});
    if q==2
        return;
    end
    h = SDgui(filename, 'userargs');    
    probe = loadSD(probe, SD);
end
probe = preRegister(probe, headsurf, refpts);




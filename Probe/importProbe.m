function probe = importProbe(probe, filename, headsurf, refpts)
global SD

SD = [];

[pname, fname, ext] = fileparts(filename);
pname = filesepStandard(pname);
switch lower(ext)
    case '.txt'

        probe.optpos   = load([pname, fname, ext], '-ascii');
        probe.nopt     = size(probe.optpos,1);
        probe.noptorig = size(probe.optpos,1);

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
if isProbeFlat(SD) && ~registrationInfo(SD)
    q = MenuBox('Flat probe does not contain enough data to register it to the head. Do you want to open probe in SDgui to add registration data?', {'Yes','No'});
    if q==2
        return;
    end
    h = SDgui(filename, 'userargs');    
    probe = loadSD(probe, SD);
end
probe = preRegister(probe, headsurf, refpts);



% ------------------------------------------------------------
function waitForGUI(h)

timer = tic;
fprintf('SDgui is busy ...\n');
while ishandle(h)
    if mod(toc(timer), 5)>4.5
        fprintf('SDgui is busy ...\n');
        timer = tic;
    end
    pause(.1);
end



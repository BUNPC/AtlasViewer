% -------------------------------------------------------------------------
function probe = checkMeasList(probe)
global logger
logger = InitLogger(logger);

if isempty(probe)
    return
end
if isempty(probe.optpos)
    return
end
if isempty(probe.srcpos)
    return
end
if isempty(probe.detpos)
    return
end

while isempty(probe.ml)
    msg{1} = sprintf('WARNING: measurement list missing from probe. Without a measurement list you can still ');
    msg{2} = sprintf('register the existing probe and run Monte Carlo but you will not be able to generate a ');
    msg{3} = sprintf('sensitivity profile. Do you want to choose a probe file from which to copy a measurement list?');
    logger.Write(msg);
    q = MenuBox(msg, {'YES','NO'});
    if q==1
        [fname, pname] = uigetfile({'*.SD';'*.nirs';'*.snirf'});
        fnameFull = filesepStandard([pname, '/', fname]);
        if ispathvalid(fnameFull)
            probeSD = loadSD(probe, fnameFull);
        end
        logger.Write('Selecting  ''YES'':  probe file - %s\n', fnameFull);
    else
        logger.Write('Selecting  ''NO''\n');
        break;
    end
    probe.ml = probeSD.ml;
end
if isempty(probe.ml)
    return
end
probe = findMeasMidPts(probe);



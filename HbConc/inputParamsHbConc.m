function hbconc = inputParamsHbConc(hbconc)

if isempty(hbconc)
    return;
end
if isempty(hbconc.config)
    return;
end

params = fieldnames(hbconc.config);
defaultVals = cell(length(params), 1);
dlgParamLabels = cell(length(params), 1);
for ii=1:length(params)
    eval(sprintf('defaultVals{ii} = num2str(hbconc.config.%s);', params{ii}));
    dlgParamLabels{ii} = getParamLabel(params{ii}, hbconc.tHRF);
end

% Set number of photons
answer = inputdlg(dlgParamLabels, 'Hb Conc Parameters', 1, defaultVals, 'on');
if isempty(answer)
    hbconc = [];
    return;
end
while 1
    err=zeros(1,length(params));
    for ii=1:length(answer)
        if ~isnumber(answer{ii})
            err(ii)=1;
        end
        if length(str2num(answer{ii})) > 1
            err(ii)=2;
        end
    end
    if ~all(err==0)
        q = menu(sprintf('Invalid input for parameter # %d. Do you want to try again?', ii),'Yes','No');
        if q==2
            hbconc = [];
            return;
        end
        answer = inputdlg(params,'Hb Conc Parameters', 1, defaultVals,'on');
        if isempty(answer)
            hbconc = [];
            return;
        end
        continue;
    end
    for ii=1:length(answer)
        eval(sprintf('hbconc.config.%s = str2num(answer{ii});', params{ii}));
    end
    break;
end

% Restore old values if there is input error
for ii=1:length(params)
    if errCheckParam(params{ii}, str2num(answer{ii}), hbconc.tHRF)
        eval(sprintf('hbconc.config.%s = str2num(defaultVals{ii});', params{ii}));
    end
end



% ------------------------------------------------------------------------
function label = getParamLabel(param, tHRF)

label='';

switch param
    case 'tRangeMin'
        label = [param, ': ', num2str(tHRF(1))];
    case 'tRangeMax'
        label = [param, ': ', num2str(tHRF(end))];
end



% ------------------------------------------------------------------------
function err = errCheckParam(param, val, tHRF)

err = false;

switch param
    case 'tRangeMin'
        if val < tHRF(1)
            err=true;
        end
    case 'tRangeMax'
        if val > tHRF(end)
            err=true;
        end
end

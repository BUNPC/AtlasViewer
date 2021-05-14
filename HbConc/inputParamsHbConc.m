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
    eval(sprintf('defaultVals{ii} = sprintf(''%%0.4f'', hbconc.config.%s);', params{ii}));
    dlgParamLabels{ii} = getParamLabel(params{ii}, hbconc.tHRF);
end

% Set number of photons
answer = inputdlg(dlgParamLabels, 'Hb Conc Parameters', 1, defaultVals, 'on');
if isempty(answer)
    hbconc = [];
    return;
end
while 1
    err = zeros(1,length(params));
    for ii = 1:length(answer)
        if ~isnumber(answer{ii})
            err(ii)=1;
        end
        if length(str2num(answer{ii})) > 1
            err(ii)=2;
        end        
        if err(ii) ~= 0
            q = MenuBox(sprintf('Invalid input for parameter # %d. Do you want to try again?', ii), {'Yes','No'});
            if q==2
                hbconc = [];
                return;
            end
            answer = inputdlg(params,'Hb Conc Parameters', 1, defaultVals,'on');
            if isempty(answer)
                hbconc = [];
                return;
            end
        end        
    end
    if ~all(err==0)
        continue;
    end
    break
end

% Restore old values if there is input error
for ii=1:length(params)
    eval(sprintf('hbconc.config.%s = str2num(answer{ii});', params{ii}));
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

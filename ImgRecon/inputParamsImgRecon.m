function imgrecon = inputParamsImgRecon(imgrecon)

if ~isempty(imgrecon.localizationError) & ~isempty(imgrecon.resolution)
    imgrecon = [];
    return;
end

params = fieldnames(imgrecon.imageParams);
defaultVals={};
for ii=1:length(params)
    eval(sprintf('defaultVals{ii} = num2str(imgrecon.imageParams.%s);', params{ii}));
end
      
% Set number of photons
answer = inputdlg(params,'Image Parameters', 1, defaultVals,'on');
if isempty(answer)
    imgrecon = [];
    return;
end
while 1
    err=zeros(1,length(params));
    for ii=1:length(answer)
        if ~isnumber(answer{ii})
            err{ii}=1;
        end
        if length(str2num(answer{ii})) > 1
            err{ii}=2;
        end
    end
    if ~all(err==0)
        q = menu(sprintf('Invalid input for parameter # %d. Do you want to try again?', ii),'Yes','No');
        if q==2
            imgrecon = [];
            return;
        end
        answer = inputdlg(params,'Image Parameters', 1, defaultVals,'on');
        if isempty(answer)
            imgrecon = [];
            return;
        end
        continue;
    end
    for ii=1:length(answer)
        eval(sprintf('imgrecon.imageParams.%s = str2num(answer{ii});', params{ii}));
    end
    break;
end


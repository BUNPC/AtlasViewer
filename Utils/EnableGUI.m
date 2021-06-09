function EnableGUI(hf, onoff)
if nargin==0
    warning('Invalid argument');
    return;
end
if ~ishandles(hf)
    warning('Invalid argument');
    return
end
if ~exist('onoff','var')
    onoff = 'on';
end
if ~ischar(onoff)
    warning('Invalid argument');
    return;
end
if ~strcmp(onoff,'on') && ~strcmp(onoff,'off')
    warning('Invalid argument');
    return;
end

hc = get(hf, 'children');
for ii = 1:length(hc)
    if isproperty(hc(ii), 'enable')
        set(hc(ii), 'enable', onoff);
    end
    if strcmp(get(hc(ii), 'type'), 'uipanel')
        EnableGUI(hc(ii), onoff)
    end
end


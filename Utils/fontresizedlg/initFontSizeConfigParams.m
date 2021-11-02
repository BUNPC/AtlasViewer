function obj = initFontSizeConfigParams(obj, name)
global cfg

cfg = InitConfig(cfg);

textSize = str2num(cfg.GetValue([name, ' Font Size']));
circleSize = str2num(cfg.GetValue([name, ' Circle Size']));
if ~isempty(textSize)
    obj.handles.textSize = textSize;
end
if ~isempty(circleSize)
    obj.handles.circleSize = circleSize;
end


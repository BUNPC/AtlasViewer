function obj = resizeFonts(obj)
global resizedlg

if iscell(obj.name)
    name = obj.name{end};
else
    name = obj.name;
end

waitForGui(FontSizeDlg(obj, [name, ' Font Resize']));
savePermanent(obj, name);

obj.handles.textSize = resizedlg.output(1);
obj.handles.circleSize = resizedlg.output(2);
if ishandles(obj.handles.labels)
    set(obj.handles.labels, 'fontsize',obj.handles.textSize);
end
if ishandles(obj.handles.circles)
    set(obj.handles.circles, 'markersize',obj.handles.circleSize);
end



% ------------------------------------------------
function savePermanent(obj, name)
global resizedlg

cfg = ConfigFileClass();
if obj.handles.textSize ~= resizedlg.output(1)
   cfg.SetValue([name, ' Font Size'], num2str(resizedlg.output(1)));
end
if obj.handles.circleSize ~= resizedlg.output(2)
   cfg.SetValue([name, ' Circle Size'], num2str(resizedlg.output(2)));
end
if cfg.Modified()
    cfg.Save();
end

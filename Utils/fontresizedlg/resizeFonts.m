function obj = resizeFonts(obj, name)
global resizedlg

waitForGui(FontSizeDlg(obj, [name, ' Font Resize']));
savePermanent(name);

obj.handles.textSize = resizedlg.output(1);
obj.handles.circleSize = resizedlg.output(2);
if ishandles(obj.handles.labels)
    set(obj.handles.labels, 'fontsize',obj.handles.textSize);
end
if ishandles(obj.handles.circles)
    set(obj.handles.circles, 'markersize',obj.handles.circleSize);
end



% ------------------------------------------------
function savePermanent(name)
global resizedlg
global cfg

cfg = InitConfig(cfg);

cfg.SetValue([name, ' Font Size'], num2str(resizedlg.output(1)));
cfg.SetValue([name, ' Circle Size'], num2str(resizedlg.output(2)));
if cfg.Modified()
    cfg.Save();
end

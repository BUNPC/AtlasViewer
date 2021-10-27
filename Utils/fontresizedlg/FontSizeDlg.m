function varargout = FontSizeDlg(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FontSizeDlg_OpeningFcn, ...
                   'gui_OutputFcn',  @FontSizeDlg_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end



% ------------------------------------------------------------------
function Initialize(handles, args)
global resizedlg

if isempty(resizedlg)
    resizedlg.output = [];
    resizedlg.hlabels = [];
    resizedlg.hcircles = [];
    resizedlg.maxmin = [5, 15; 10, 50];
    resizedlg.dlgname = '';
end

if ~exist('args','var')
    args = {};
end

if length(args)>0  && ~isempty(args{1}) %#ok<ISMT>
    if ishandles(args{1}.handles.labels)
        resizedlg.hlabels = args{1}.handles.labels;
    end
    if ishandles(args{1}.handles.circles)
        resizedlg.hcircles = args{1}.handles.circles;
    end
end
if length(args)>1 && ~isempty(args{2})
    resizedlg.dlgname = args{2};
else
    resizedlg.dlgname = get(handles.figure1,'name');
end


% Get initial font size percentage based on external graphic object size if it exists
if ishandles(resizedlg.hlabels)
    fs = get(resizedlg.hlabels(1), 'fontsize');
    sliderval_fs = fs2slider(fs);
else
    sliderval_fs = get(handles.sliderFontResize, 'value');
    fs = slider2fs(sliderval_fs);
end

% Get initial circle size percentage based on external graphic object size if it exists
if ishandles(resizedlg.hcircles)
    cs = get(resizedlg.hcircles(1), 'markersize');
    sliderval_cs = cs2slider(cs);
else
    sliderval_cs = get(handles.sliderCircleResize, 'value');
    cs = slider2cs(sliderval_cs);
end

resizedlg.output = [fs, cs];

set(handles.editFontResize, 'string', num2str(fs));
set(handles.sliderFontResize, 'value', sliderval_fs);
set(handles.editFontSizeMin, 'string', resizedlg.maxmin(1,1));
set(handles.editFontSizeMax, 'string', resizedlg.maxmin(1,2));
UpdateFontSize(handles, fs);

set(handles.editCircleResize, 'string', num2str(cs));
set(handles.sliderCircleResize, 'value', sliderval_cs);
set(handles.editCircleSizeMin, 'string', resizedlg.maxmin(2,1));
set(handles.editCircleSizeMax, 'string', resizedlg.maxmin(2,2));
UpdateCircleSize(handles, cs);



% ------------------------------------------------------------------
function FontSizeDlg_OpeningFcn(hObject, ~, handles, varargin)
global resizedlg

resizedlg = [];
Initialize(handles, varargin);
set(handles.figure1, 'name', resizedlg.dlgname);
set(handles.textDlgName, 'string', resizedlg.dlgname);

handles.output = hObject;
guidata(hObject, handles);



% ------------------------------------------------------------------
function varargout = FontSizeDlg_OutputFcn(~, ~, handles) 
varargout{1} = handles.figure1;



% ------------------------------------------------------------------
function fs = slider2fs(slider)
global resizedlg
fs = uint32(resizedlg.maxmin(1,1) + slider*(resizedlg.maxmin(1,2)-resizedlg.maxmin(1,1)));



% ------------------------------------------------------------------
function slider = fs2slider(fs)
global resizedlg
slider = (round(fs) - resizedlg.maxmin(1,1))/(resizedlg.maxmin(1,2)-resizedlg.maxmin(1,1));



% ------------------------------------------------------------------
function cs = slider2cs(slider)
global resizedlg
cs = uint32(resizedlg.maxmin(2,1) + slider*(resizedlg.maxmin(2,2)-resizedlg.maxmin(2,1)));



% ------------------------------------------------------------------
function slider = cs2slider(cs)
global resizedlg
slider = (round(cs) - resizedlg.maxmin(2,1))/(resizedlg.maxmin(2,2)-resizedlg.maxmin(2,1));



% ------------------------------------------------------------------
function sliderFontResize_Callback(hObject, ~, handles) %#ok<*DEFNU>
val = get(hObject, 'value');
fs = slider2fs(val);
set(handles.editFontResize, 'string', num2str(fs));
UpdateFontSize(handles, fs);



% ------------------------------------------------------------------
function editFontResize_Callback(hObject, ~, handles)
global resizedlg
s = get(hObject, 'string');
if ~isnumber(s)
    p = get(handles.sliderFontResize, 'value');
    fsprev = slider2fs(p);
    set(hObject, 'string',num2str(fsprev))
    return;
end
fs = str2num(s);
if fs<resizedlg.maxmin(1,1) || fs>resizedlg.maxmin(1,2)
    p = get(handles.sliderFontResize, 'value');
    fsprev = slider2fs(p);
    set(hObject, 'string',num2str(fsprev))
    return;
end
set(handles.sliderFontResize, 'value', fs2slider(fs));
UpdateFontSize(handles, fs);



% -------------------------------------------------------------------
function sliderCircleResize_Callback(hObject, ~, handles)
val = get(hObject, 'value');
cs = slider2cs(val);
set(handles.editCircleResize, 'string', num2str(cs));
UpdateCircleSize(handles, cs);



% -------------------------------------------------------------------
function editCircleResize_Callback(hObject, ~, handles)
global resizedlg
s = get(hObject, 'string');
if ~isnumber(s)
    p = get(handles.sliderCircleResize, 'value');
    csprev = slider2cs(p);
    set(hObject, 'string',num2str(csprev))
    return;
end
cs = str2num(s);
if cs<resizedlg.maxmin(2,1) || cs>resizedlg.maxmin(2,2)
    p = get(handles.sliderCircleResize, 'value');
    csprev = slider2cs(p);
    set(hObject, 'string',num2str(csprev))
    return;
end
set(handles.sliderCircleResize, 'value', cs2slider(cs));
UpdateCircleSize(handles, cs);




% ------------------------------------------------------------------
function pushbuttonSave_Callback(~, ~, handles)
global resizedlg

p = str2num(get(handles.editFontResize, 'string'));
fs = UpdateFontSize(handles, p);

p = str2num(get(handles.editCircleResize, 'string'));
cs = UpdateCircleSize(handles, p);

resizedlg.output = [fs, cs];
close(handles.figure1);



% ------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
close(handles.figure1);



% ------------------------------------------------------------------
function sz = UpdateFontSize(handles, sz)
global resizedlg
set(handles.textShowFontSize, 'fontsize',sz);
if ishandles(resizedlg.hlabels)
    set(resizedlg.hlabels, 'fontsize',sz);
end


% ------------------------------------------------------------------
function sz = UpdateCircleSize(handles, sz)
global resizedlg
setMarkerSize(handles.axesShowCircleSize, sz);
if ishandles(resizedlg.hcircles)
    set(resizedlg.hcircles, 'markersize',sz);
end


% -------------------------------------------------------------------
function sz = percentToFontSize(val)
global resizedlg
sz = resizedlg.maxmin(1,1) + (val*(resizedlg.maxmin(1,2)-resizedlg.maxmin(1,1)));



% -------------------------------------------------------------------
function sz = percentToCircleSize(val)
global resizedlg
sz = resizedlg.maxmin(2,1) + (val*(resizedlg.maxmin(2,2)-resizedlg.maxmin(2,1)));



% -------------------------------------------------------------------
function val = fontSizeToPercentage(sz)
global resizedlg
val = (sz - resizedlg.maxmin(1,1)) / (resizedlg.maxmin(1,2)-resizedlg.maxmin(1,1));



% -------------------------------------------------------------------
function val = circleSizeToPercentage(sz)
global resizedlg
val = (sz - resizedlg.maxmin(2,1)) / (resizedlg.maxmin(2,2)-resizedlg.maxmin(2,1));



% -------------------------------------------------------------------
function setMarkerSize(haxes, ms)
hc = get(haxes, 'children');

if isempty(hc)
    xlim = get(haxes, 'xlim');
    ylim = get(haxes, 'xlim');
    c = [xlim(1) + (xlim(2)-xlim(1))/2, ylim(1) + (ylim(2)-ylim(1))/2];
    plot(haxes, c(1), c(2), '.', 'color','k');
    set(haxes, 'XTickMode','manual', 'yTickMode','manual', 'XTickLabel',{},'yTickLabel',{}, ...
        'xgrid','off','ygrid','off','color',[0.941, 0.941, 0.941])
    hc = get(haxes, 'children');
end

for ii = 1:length(hc)
    if strcmpi(get(hc(ii), 'type'), 'line')
        set(hc(ii), 'markersize',ms);
    end
end



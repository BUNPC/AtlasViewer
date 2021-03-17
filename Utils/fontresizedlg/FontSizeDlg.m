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
function val = Initialize(handles, args)
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
    percent_fs = fontSizeToPercentage(fs);
else
    percent_fs = get(handles.sliderFontResize, 'value');
    fs = percentToFontSize(percent_fs);
end

% Get initial circle size percentage based on external graphic object size if it exists
if ishandles(resizedlg.hcircles)
    cs = get(resizedlg.hcircles(1), 'markersize');
    percent_cs = circleSizeToPercentage(cs);
else
    percent_cs = get(handles.sliderCircleResize, 'value');
    cs = percentToCircleSize(percent_cs);
end

resizedlg.output = [fs, cs];

set(handles.editFontResize, 'string', num2str(uint32(100*percent_fs)));
set(handles.sliderFontResize, 'value', percent_fs);
UpdateFontSize(handles, percent_fs)

set(handles.editCircleResize, 'string', num2str(uint32(100*percent_cs)));
set(handles.sliderCircleResize, 'value', percent_cs);
UpdateCircleSize(handles, percent_cs)



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
function sliderFontResize_Callback(hObject, ~, handles) %#ok<*DEFNU>
val = get(hObject, 'value');
set(handles.editFontResize, 'string', num2str(uint32(val*100)));
UpdateFontSize(handles, val);



% ------------------------------------------------------------------
function editFontResize_Callback(hObject, ~, handles)
val = str2num(get(hObject, 'string'));
set(handles.sliderFontResize, 'value', val/100);
UpdateFontSize(handles, val/100);



% -------------------------------------------------------------------
function sliderCircleResize_Callback(hObject, ~, handles)
val = get(hObject, 'value');
set(handles.editCircleResize, 'string', num2str(uint32(val*100)));
UpdateCircleSize(handles, val);



% -------------------------------------------------------------------
function editCircleResize_Callback(hObject, ~, handles)
val = str2num(get(hObject, 'string'));
set(handles.sliderCircleResize, 'value', val/100);
UpdateCircleSize(handles, val/100);



% ------------------------------------------------------------------
function pushbuttonSave_Callback(~, ~, handles)
global resizedlg

p = str2num(get(handles.editFontResize, 'string'));
fs = UpdateFontSize(handles, p/100);

p = str2num(get(handles.editCircleResize, 'string'));
cs = UpdateCircleSize(handles, p/100);

resizedlg.output = [fs, cs];
close(handles.figure1);



% ------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
close(handles.figure1);



% ------------------------------------------------------------------
function sz = UpdateFontSize(handles, val)
global resizedlg
sz = percentToFontSize(val);
set(handles.textShowFontSize, 'fontsize',sz);
if ishandles(resizedlg.hlabels)
    set(resizedlg.hlabels, 'fontsize',sz);
end


% ------------------------------------------------------------------
function sz = UpdateCircleSize(handles, val)
global resizedlg
sz = percentToCircleSize(val);
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



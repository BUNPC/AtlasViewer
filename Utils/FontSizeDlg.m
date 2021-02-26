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
function val = Initialize(handles)
global resizedlg

val = (resizedlg.size - resizedlg.limits(1)) / ...
    (resizedlg.limits(2) - resizedlg.limits(1));

set(handles.sliderResize, 'value', val);
set(handles.editResize, 'string', num2str(uint32(100*val)));
set(handles.figure1, 'name', resizedlg.dlgname);
set(handles.textDlgName, 'string', resizedlg.dlgname);
set(handles.textShowFontSize, 'fontsize', resizedlg.size);



% ------------------------------------------------------------------
function FontSizeDlg_OpeningFcn(hObject, ~, handles, varargin)
global resizedlg

if length(varargin)>1 && ~isempty(varargin{2})
    resizedlg.limits = varargin{2};
else
    resizedlg.limits = [0, 100];
end
if length(varargin)>0  && ~isempty(varargin{1}) %#ok<ISMT>
    if ishandles(varargin{1})
        resizedlg.hobj = varargin{1};
        resizedlg.size = get(varargin{1}(1), 'fontsize');
    else
        resizedlg.hobj = [];
        resizedlg.size = varargin{1};
    end
else
    resizedlg.size = uint32((resizedlg.limits(2)-resizedlg.limits(1))/2);
end
if length(varargin)>2 && ~isempty(varargin{3})
    resizedlg.dlgname = varargin{3};
else
    resizedlg.dlgname = get(hObject,'name');
end
Initialize(handles);
handles.output = hObject;
guidata(hObject, handles);



% ------------------------------------------------------------------
function varargout = FontSizeDlg_OutputFcn(~, ~, handles) 
varargout{1} = handles.figure1;



% ------------------------------------------------------------------
function sliderResize_Callback(hObject, ~, handles) %#ok<*DEFNU>
val = get(hObject, 'value');
set(handles.editResize, 'string', num2str(uint32(val*100)));
UpdateFontSize(handles, val);



% ------------------------------------------------------------------
function editResize_Callback(hObject, ~, handles)
val = str2num(get(hObject, 'string'));
set(handles.sliderResize, 'value', val/100);
UpdateFontSize(handles, val/100);



% ------------------------------------------------------------------
function pushbuttonSave_Callback(~, ~, handles)
global resizedlg
size = str2num(get(handles.editResize, 'string'));
resizedlg.size = resizedlg.limits(1) + ...
    uint32((resizedlg.limits(2)-resizedlg.limits(1))*(size/100));
UpdateFontSize(handles, size/100);
close(handles.figure1);



% ------------------------------------------------------------------
function pushbuttonCancel_Callback(~, ~, handles)
val = Initialize(handles);
UpdateFontSize(handles, val);
close(handles.figure1);



% ------------------------------------------------------------------
function UpdateFontSize(handles, val)
global resizedlg
sz = uint32(resizedlg.limits(1)  +  (resizedlg.limits(2)-resizedlg.limits(1))*val);
set(handles.textShowFontSize, 'fontsize',sz);
if ~ishandles(resizedlg.hobj)
    return;
end
set(resizedlg.hobj, 'fontsize',sz);



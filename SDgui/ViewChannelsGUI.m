function varargout = ViewChannelsGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ViewChannelsGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ViewChannelsGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1}) && ~strcmp(varargin{end},'userargs')
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end



% ---------------------------------------------------------------------------
function ViewChannelsGUI_OpeningFcn(hObject, ~, handles, varargin)
global viewchannels
global SD

InitChannelsTbl(handles)

viewchannels = struct('handles',struct('mbox',[]));

handles.output = hObject;
guidata(hObject, handles);

if isempty(SD) || ~isempty(varargin)
    [filename, pathname] = getCurrPathname(varargin);
    if ~isempty(filename)
        load([pathname, filename], '-mat');
    end    
end

% Error checks
if isempty(SD)
    return;
end
if ~isfield(SD, 'MeasList') || isempty(SD.MeasList)
    return;
end

% If we're here then meas list exists so load it
UpdateChannelsTbl(handles);




% ---------------------------------------------------------------------------
function varargout = ViewChannelsGUI_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;



% ---------------------------------------------------------------------------
function checkboxSort_Callback(hObject, ~, ~) %#ok<*DEFNU>
global viewchannels

if get(hObject, 'value')
    viewchannels.handles.mbox = MessageBox('This feature will be implemented soon ...','Not Yet Implemented','nowait');
    set(viewchannels.handles.mbox, 'units','characters');
    p = get(viewchannels.handles.mbox, 'position');
    set(viewchannels.handles.mbox, 'position',[p(1), p(2), p(3)*1.5, p(4)]);
else
    if ~isempty(viewchannels.handles)
        if ishandle(viewchannels.handles.mbox)
            delete(viewchannels.handles.mbox)
        end
    end
end




% ---------------------------------------------------------------------------
function InitChannelsTbl(handles)
w = 75;
A = [];
cnames = {'Source', 'Detector', 'Wavelength'};
cwidth = {w, w, w};
ceditable = logical([0,0,0]);
cformat = {'short', 'short', 'short'};
set(handles.uitableChannels, ...
    'Data',A, ...
    'ColumnName',cnames, ...
    'ColumnWidth',cwidth, ...
    'ColumnEditable',ceditable, ...
    'ColumnFormat',cformat);



% ---------------------------------------------------------------------------
function UpdateChannelsTbl(handles)
global SD
A = [SD.MeasList(:,1:2), SD.MeasList(:,4)];
set(handles.uitableChannels, 'Data',A)



% ---------------------------------------------------------------------------
function pushbuttonUpdate_Callback(hObject, eventdata, handles)
UpdateChannelsTbl(handles);



% ---------------------------------------------------------------------------
function pushbuttonExit_Callback(hObject, eventdata, handles)
delete(handles.figure1);

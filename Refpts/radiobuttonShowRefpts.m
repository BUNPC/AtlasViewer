function radiobuttonShowRefpts(hObject, eventdata, handles)

% The addition of the class(eventdata) condition is for Matlab 2014b compatibility
if ~isempty(eventdata) & ~strcmp(class(eventdata), 'matlab.ui.eventdata.ActionData')
    refpts = eventdata; 
else
    global atlasViewer;
    refpts = atlasViewer.refpts;
end

hLabels = refpts.handles.labels;
hCircles = refpts.handles.circles;

if strcmp(get(hObject, 'tag'), 'radiobuttonShowRefptsLabels')
    hObject2 = refpts.handles.radiobuttonShowRefptsCircles;
    h1 = hLabels; 
    h2 = hCircles; 
else
    hObject2 = refpts.handles.radiobuttonShowRefptsLabels;
    h1 = hCircles; 
    h2 = hLabels; 
end

val1 = get(hObject,'value');
val2 = get(hObject2,'value');
if val1==1
    set(hObject2, 'value', 0)
    set(h1(:,1),'visible','on');
    set(h1(:,2),'visible','off');
    set(h2,'visible','off');
elseif val2==1
    set(hObject, 'value', 0)
    set(h2(:,1),'visible','on');
    set(h2(:,2),'visible','off');
    set(h1,'visible','off');
else
    set(h1,'visible','off');
    set(h2,'visible','off');
end

function uipanelBrainDisplay(hObject, eventdata, handles)

if(iscell(eventdata))
    pialsurf = eventdata{1};
    labelssurf = eventdata{2};
else
    global atlasViewer;
    pialsurf = atlasViewer.pialsurf;
    labelssurf = atlasViewer.labelssurf;    
end

if ~isempty(pialsurf)
    hPialSurf = pialsurf.handles.surf;
    hObject1 = pialsurf.handles.radiobuttonShowPial;
    val1 = get(hObject1,'value');
    enable1 = get(hObject1,'enable');
else
    hPialSurf = [];
    hObject1 = [];
    val1 = -1;
    enable1 = '';
end

if ~isempty(labelssurf)
    hLabelsSurf = labelssurf.handles.surf;
    hObject2 = labelssurf.handles.radiobuttonShowLabels;
    val2 = get(hObject2,'value');
    enable2 = get(hObject2,'enable');
else
    hLabelsSurf = [];
    hObject2 = [];
    val2 = -1;
    enable2 = '';
end


if hObject == hObject1
    if val1==1
        set(hObject2,'value',0);        
        if strcmp(enable1,'on')
            set(hPialSurf,'visible','on');
        end
        if strcmp(enable2,'on')
            set(hLabelsSurf,'visible','off');
        end
    elseif val1==0 && val2==1
        % This should never happen (means we're displaying labels and pial 
        % simultaneously which is the wrong thing to do) but for completeness 
        % we add this case.
        if strcmp(enable1,'on')
            set(hPialSurf,'visible','off');
        end
        if strcmp(enable2,'on')
            set(hLabelsSurf,'visible','on');
        end
    elseif val1==0 && val2==0
        if strcmp(enable1,'on')
            set(hPialSurf,'visible','off');
        end
        if strcmp(enable2,'on')
            set(hLabelsSurf,'visible','off');
        end
    end
elseif hObject == hObject2
    if val2==1
        set(hObject1,'value',0);
        if strcmp(enable2,'on')
            set(hLabelsSurf,'visible','on');
        end
        if strcmp(enable1,'on')
            set(hPialSurf,'visible','off');
        end
    elseif val1==0 && val2==1
        % This should never happen (means we're displaying labels and pial 
        % simultaneously which is the wrong thing to do) but for completeness 
        % we add this case.
        if strcmp(enable2,'on')
            set(hLabelsSurf,'visible','off');
        end
        if strcmp(enable1,'on')
            set(hPialSurf,'visible','on');
        end
    elseif val2==0 && val1==0
        if strcmp(enable2,'on')
            set(hLabelsSurf,'visible','off');
        end
        if strcmp(enable1,'on')
            set(hPialSurf,'visible','off');
        end
    end
end

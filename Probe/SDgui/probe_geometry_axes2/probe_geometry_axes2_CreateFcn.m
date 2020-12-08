function probe_geometry_axes2_CreateFcn(hObject, eventdata, handles)

    cla(hObject);
    set(hObject, 'xlim', [0 100]);
    set(hObject, 'ylim', [0 100]);
    set(hObject, 'zlim', [0 100]);
    set(hObject, 'xgrid', 'on');
    set(hObject, 'ygrid', 'on');
    set(hObject, 'zgrid', 'on');

    set(hObject,'units','pixels')
    p=get(hObject, 'position');
    set(hObject,'units','normalized');

    if ~verLessThan('matlab', 'R2014b')
        hXlabel = get(hObject, 'xlabel');
        hYlabel = get(hObject, 'ylabel');
        hZlabel = get(hObject, 'zlabel');
        set(hXlabel,'string','X');
        set(hYlabel,'string','Y','rotation',0);
        set(hZlabel,'string','Z','rotation',0);
    end
    
    edges=struct('color',[.45 .85 .65],'thickness',2,'handles',[]);
    probe_geometry_axes2_data=struct('optselect',[],'h_nodes',[],'edges',edges,'fontsize',[11 14],...
                                     'view','xy','threshold',[0 0 0],...
                                     'fontcolor',[1.00 0.00 0.00; 0.85 0.45 0.55],...
                                     'fontcolor_dummy',[0.20 0.30 0.25; 0.30 0.40 0.35],...
                                     'noptorig',0);
    set(hObject,'userdata',probe_geometry_axes2_data);

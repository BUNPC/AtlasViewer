function probe_geometry_axes_CreateFcn(hObject, eventdata, handles)

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
    offset=40;
    
    if ~verLessThan('matlab', 'R2014b')
        hXlabel = get(hObject, 'xlabel');
        hYlabel = get(hObject, 'ylabel');
        hZlabel = get(hObject, 'zlabel');
        set(hXlabel,'string','X');
        set(hYlabel,'string','Y','rotation',0);
        set(hZlabel,'string','Z','rotation',0);
    end
    
    optselect=struct('src',[],'det',[]);
    edges=struct('color',[.45 .85 .65],'thickness',2,'handles',[]);
    probe_geometry_axes_data=struct('optselect',optselect,'h_nodes_s',[],'h_nodes_d',[],'h_nodes_dummy',[],...
                                    'edges',edges,'fontsize',[11 14],'fontsize_dummy',[11 14],'view','xy',...
                                    'threshold',[0 0 0],...
                                    'fontcolor_s',[1.00 0.00 0.00; 0.85 0.45 0.55],...
                                    'fontcolor_d',[0.00 0.00 1.00; 0.55 0.45 0.85],...
                                    'fontcolor_dummy',[1.00 0.00 1.00; 0.85 0.35 0.85]);
    set(hObject,'userdata',probe_geometry_axes_data);


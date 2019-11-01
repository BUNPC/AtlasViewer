function optode_src_tbl_Init(handles,OptPos,SrcMap);

    hObject = handles.optode_src_tbl;    
    srcmap_show = optode_src_tbl_srcmap_show_GetVal(handles);

    A=repmat({'' '' ''},100,1);
    cnames={'x','y','z'};
    cwidth={40,40,40};
    ceditable=logical([1 1 1]);
    for i=1:size(OptPos,1)
        A{i,1}=num2str(OptPos(i,1));
        A{i,2}=num2str(OptPos(i,2));
        A{i,3}=num2str(OptPos(i,3));
    end
    if(srcmap_show)      
        for j=1:size(SrcMap,1)
            A(:,3+j)={''};
            for i=1:size(OptPos,1)
                A{i,3+j}=num2str(SrcMap(j,i));
            end
            cnames{end+1}=['l' num2str(j)];
            cwidth{end+1}=20;
            ceditable(end+1)=logical(1);
        end
    end
    set(handles.optode_src_tbl,'Data',A,'ColumnName',cnames,'ColumnWidth',...
        cwidth,'ColumnEditable',ceditable);
    userdata.tbl_size = size(OptPos,1);
    userdata.selection = [];
    set(hObject, 'userdata',userdata);

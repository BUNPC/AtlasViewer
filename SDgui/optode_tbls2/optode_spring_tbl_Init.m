function optode_spring_tbl_Init(handles,sl)

    hObject = handles.optode_spring_tbl;

    A=repmat({'' '' ''},300,1);
    cnames={'opt1 idx','opt2 idx','length'};
    cwidth={40,40,50};
    ceditable=logical([1 1 1]);
    for i=1:size(sl,1)
        A{i,1}=num2str(sl(i,1));
        A{i,2}=num2str(sl(i,2));
        A{i,3}=num2str(sl(i,3));
    end
    set(handles.optode_spring_tbl,'Data',A,'ColumnName',cnames,'ColumnWidth',...
        cwidth,'ColumnEditable',ceditable);
    userdata.tbl_size = size(sl,1);
    userdata.selection = [];
    set(hObject, 'userdata',userdata);

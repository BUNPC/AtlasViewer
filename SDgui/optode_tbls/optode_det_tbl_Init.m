function optode_det_tbl_Init(handles,OptPos);

    hObject = handles.optode_det_tbl;

    A=repmat({'' '' ''},200,1);
    for i=1:size(OptPos,1)
        A{i,1}=num2str(OptPos(i,1));
        A{i,2}=num2str(OptPos(i,2));
        A{i,3}=num2str(OptPos(i,3));
    end
    set(hObject, 'data', A);
    userdata.tbl_size = size(OptPos,1);
    userdata.selection = [];
    set(hObject, 'userdata',userdata);

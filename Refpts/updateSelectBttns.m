function updateSelectBttns(refpts)

handles        = getappdata(gcf, 'handles');
colBttnUnselPt = getappdata(gcf, 'colBttnUnselPt');
colBttnSelPt   = getappdata(gcf, 'colBttnSelPt');

labels_basic = {'Nz','Iz','LPA','RPA','Cz'};

for jj=1:length(labels_basic)
    
    % Get button handle for the current ref point 
    switch lower(labels_basic{jj})
        case 'nz'
            hBttn = handles.pushbuttonSelectNz;
        case 'iz'
            hBttn = handles.pushbuttonSelectIz;
        case 'cz'
            hBttn = handles.pushbuttonSelectCz;
        case 'lpa'
            hBttn = handles.pushbuttonSelectLPA;
        case 'rpa'
            hBttn = handles.pushbuttonSelectRPA;            
    end
    
    % Get the foreground and background colors based on 
    if ismember(labels_basic{jj}, refpts.labels)
        col_b = colBttnSelPt(1,:);
        col_f = colBttnSelPt(2,:);
        caption = sprintf('Reselect %s', labels_basic{jj});
    else
        col_b = colBttnUnselPt(1,:);
        col_f = colBttnUnselPt(2,:);
        caption = sprintf('Select %s', labels_basic{jj});
    end
    set(hBttn, 'backgroundcolor',col_b, 'foregroundcolor',col_f, 'string',caption);
    
end
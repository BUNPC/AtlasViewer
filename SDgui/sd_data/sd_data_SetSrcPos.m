function sd_data_SetSrcPos(i,pos)

    global SD;
    SD.SrcPos(i,:)=pos;
    

    % Update AtlasViewerGUI
    SDgui_AtlasViewerGUI('update');


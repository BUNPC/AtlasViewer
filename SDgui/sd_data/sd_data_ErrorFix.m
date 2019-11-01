function err = sd_data_ErrorFix()

    global SD;
    
    err = false;
    
    % SrcPos
    if(~isfield(SD,'SrcPos'))
        SD.SrcPos=[];
    end
    
    % DetPos
    if(~isfield(SD,'DetPos'))
        SD.DetPos=[];
    end
    
    % SrcPos
    SD.nSrcs=size(SD.SrcPos,1);

    % DetPos
    SD.nDets=size(SD.DetPos,1);

    % Lambda
    ml=sd_data_GetMeasList();
    nwl=sd_data_GetNwl();
    if(~isfield(SD,'Lambda') || isempty(SD.Lambda))
        SD.Lambda=[];
    end
    
    % MesList
    if(~isfield(SD,'MeasList'))
        SD.MeasList=[];
    elseif ~isempty(SD.MeasList)
        if size(SD.MeasList,2)<3
            SD.MeasList(:,3)=1;
        end
        ml=sd_data_GetMeasList();
        nwl=sd_data_GetNwl();
        if(nwl~=length(unique(SD.MeasList(:,end))) & (SD.nSrcs>0))
            sd_data_SetMeasList(ml);
        end
    end
    
    % MesListAct
    if(isfield(SD,'MeasListAct') && isempty(SD.MeasListAct))
        SD.MeasListAct=ones(size(SD.MeasList,1),1);
    end

    
    % SpringList
    if(~isfield(SD,'SpringList'))
        SD.SpringList=[];
    end
    ii=1;
    while ii<=size(SD.SpringList,1)
        k = find(SD.SpringList(:,1)==SD.SpringList(ii,1) & SD.SpringList(:,2)==SD.SpringList(ii,2));        
        if length(k)>1 && err==false
            q = menu(sprintf('Corruption error: More than one spring for optode pair (%d,%d). Do you want to fix it by removing one spring?', ...
                             SD.SpringList(ii,1), SD.SpringList(ii,2)), 'YES','NO');
            if q==1
                SD.SpringList(k(2:end),:) = [];
            else                
                err = true;
            end            
        end
        ii=ii+1;
    end        
    
    % AnchorList
    if(~isfield(SD,'AnchorList'))
        SD.AnchorList=[];
    end
        
    % SpatialUnit
    if isfield(SD,'SpatialUnit')
        if strcmpi(SD.SpatialUnit,'cm')
            ch = menu(sprintf('We recommend Spatial Units of mm to be consistent with Homer.\nWe will convert cm to mm for you.'),'Okay','Cancel');
            if ch==1
                SD.SpatialUnit = 'mm';
                SD.SrcPos = SD.SrcPos * 10;
                SD.DetPos = SD.DetPos * 10;
                if isfield(SD,'SpringList')
                    if size(SD.SpringList,2)==3
                        lst = find(SD.SpringList(:,3)~=-1);
                        SD.SpringList(lst,3) = SD.SpringList(lst,3) * 10;
                    end
                end
            end
        end
    elseif ~isfield(SD,'SpatialUnit')
        ch = menu('What spatial units are used for the optode positions?','cm','mm','Do not know');
        if ch==1
            ch = menu('We will convert cm to mm for you.','Okay','Cancel');
            if ch==1
                SD.SpatialUnit = 'mm';
                SD.SrcPos = SD.SrcPos * 10;
                SD.DetPos = SD.DetPos * 10;
                if isfield(SD,'SpringList')
                    if size(SD.SpringList,2)==3
                        lst = find(SD.SpringList(:,3)~=-1);
                        SD.SpringList(lst,3) = SD.SpringList(lst,3) * 10;
                    end
                end
            else
                SD.SpatialUnit = 'cm';
            end
        elseif ch==2
            SD.SpatialUnit = 'mm';
        elseif ch==3
            SD.SpatialUnit = 'mm';
        end
    end

    % SrcMap
    if(~isfield(SD,'SrcMap'))
        SD.SrcMap=[];
    elseif(nwl>0 & SD.nSrcs>0 & isempty(SD.SrcMap))
        sd_data_SetSrcMapDefault();
    elseif(nwl>0 & SD.nSrcs>0 & (size(SD.SrcMap,1) ~= nwl))
        SD.SrcMap=reshape(SD.SrcMap(:),nwl,SD.nSrcs);
    end

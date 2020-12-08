function ManualCorrection_Distance(src, eventData,handles,Num_Scr,Num_Det,Num_Chn,Normal_Int)
% global SelectMode Grabbed Snap Points Weights Xi Degree Index

% Left click
if strcmpi(get(handles.figure1,'SelectionType'), 'Normal')
    
    point = get(handles.axes1, 'CurrentPoint'); % mouse click position
    camPos = get(handles.axes1, 'CameraPosition'); % camera position
    camTgt = get(handles.axes1, 'CameraTarget'); % where the camera is pointing to
    
    camDir = camPos - camTgt; % camera direction
    camUpVect = get(handles.axes1, 'CameraUpVector'); % camera 'up' vector
    
    % build an orthonormal frame based on the viewing direction and the
    % up vector (the "view frame")
    zAxis = camDir/norm(camDir);
    upAxis = camUpVect/norm(camUpVect);
    xAxis = cross(upAxis, zAxis);
    yAxis = cross(zAxis, xAxis);
    
    rot = [xAxis; yAxis; zAxis]; % view rotation
    
    %%% point cloud
    hj=handles.hj;
    AllPtns=[];
    %%% sort sources
    m=0;
    for i=1:Num_Scr
        m=m+1;
        hj = findobj(handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['S' num2str(i)]); % find optodes and their tags
        H=get(hj);
        Position=H.UserData';
        Tag=H.Tag;
        PointCloud{1,m}=hj;
        PointCloud{2,m}=Position;
        PointCloud{3,m}=Tag;
        AllPtns=[AllPtns Position];
    end
    
    %%% sort Detectors
    for i=1:Num_Det
        m=m+1;
        hj = findobj(handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['D' num2str(i)]); % find optodes and their tags
        H=get(hj);
        Position=H.UserData';
        Tag=H.Tag;
        PointCloud{1,m}=hj;
        PointCloud{2,m}=Position;
        PointCloud{3,m}=Tag;
        AllPtns=[AllPtns Position];
    end
    
    %%% sort Channels
    for i=1:Num_Chn
        m=m+1;
        hj = findobj(handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(i)]); % find optodes and their tags
        H=get(hj);
        Position=H.UserData';
        Tag=H.Tag;
        PointCloud{1,m}=hj;
        PointCloud{2,m}=Position;
        PointCloud{3,m}=Tag;
        %         AllPtns=[AllPtns Position];
    end
    
    % the point cloud represented in the view frame
    rotatedPointCloud = (rot * AllPtns);
    
    point=point(1,:);
    % the clicked point represented in the view frame
    rotatedPointFront = rot * point' ;
    
    % find the nearest neighbour to the clicked point
    pointCloudIndex = dsearchn(rotatedPointCloud(1:2,:)', ...
        rotatedPointFront(1:2)');
    
    h = findobj(handles.hj,'FaceColor','k'); %find the selected optode
    if ~isempty(h)
        Name=get(h,'Tag');
        if ~isempty(strfind(Name,'S'))
            set(h,'FaceColor','r');
        elseif ~isempty(strfind(Name,'D'))
            set(h,'FaceColor','b');
        end
    end
    
    %%%% set the color of the selected point to black
    h = findobj(handles.hj,'Tag',PointCloud{3,pointCloudIndex});
    set(h,'FaceColor','k');
    
    % Right click
elseif strcmpi(get(handles.figure1,'SelectionType'), 'Alt')
    h = findobj(handles.hj,'FaceColor','k'); % find the selected optode
    if ~isempty(h)
        X=get(h);
        hl = findobj(handles.figure1,'Type','text','String',X.Tag); % find its label
        Xt=get(hl);
        Label_Pos=Xt.Position;
        Opt_Current_Position=X.UserData; %%% current position of the selected optode
        
        %%%% remove arrows
        hk=findall(0,'Tag','Arrow');
        if ~isempty(hk)
            delete(hk)
        end
        
        %%%%% get the  faces and vertices
        hi = findobj(handles.axes1,'Tag','nd'); % get the head handle
        hj=get(hi(1));
        vertices=hj.Vertices;
        faces=hj.Faces;
        center=mean(vertices); %%% head center
        Nodes_Int=vertices;
        
        %%%% pick a new position
        dcmObj = datacursormode(handles.figure1);
        set(dcmObj,'DisplayStyle','window','SnapToDataVertex','on','Enable','on')
        
        % mouse click to pick a new position
        Point=[];
        while isempty(Point)
            pause(0.5)
            Point = getCursorInfo(dcmObj);
            if ~isempty(Point)
                selectedPoint = select3d(hi(1))';
                break
            end
        end
        datacursormode off
        
        
        Lij=1; %%% parameter used to visualize labels above each optode
        %%%% update the position of the selected optode
        set(h,'XData',X.XData-Opt_Current_Position(1)+selectedPoint(1),'YData',X.YData-Opt_Current_Position(2)+selectedPoint(2),'ZData',X.ZData-Opt_Current_Position(3)+selectedPoint(3));
        set(h,'UserData',selectedPoint);
        
        %%%% update the position of its label
        Ds=dist(Nodes_Int,selectedPoint');
        L=find(Ds==min(abs(Ds)));
        b=Normal_Int(L(1),:); %%% new normal vector for the label
        V=selectedPoint-center; %%% vector connecting the head center to the electrode
        
        %%%% compute the angle between the channel normal vector and V
        A1 = cat(4,V(1),V(2),V(3)); % Combine the three components in the 4th dimension
        B1 = cat(4,b(1),b(2),b(3)); %
        C1 = cross(A1,B1,4); % Take the cross products
        ang = radtodeg(atan2(sqrt(dot(C1,C1,4)),dot(A1,B1,4)));
        if ang>90
            b=b*-1;
        end
        set(hl,'Position',selectedPoint+Lij*b);
        set(hl,'UserData',b);
        
        %%% point cloud
        hj=handles.hj;
        AllPtns=[];
        %%% sort sources
        m=0;
        for i=1:Num_Scr
            m=m+1;
            hj = findobj(handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['S' num2str(i)]); % find optodes and their tags
            Hp=get(hj);
            Position=Hp.UserData';
            Tag=Hp.Tag;
            DisplayName=Hp.DisplayName;
            PointCloud{1,m}=hj;
            PointCloud{2,m}=Position';
            PointCloud{3,m}=Tag;
            PointCloud{4,m}=DisplayName;
            AllPtns=[AllPtns Position];
        end
        
        %%% sort Detectors
        for i=1:Num_Det
            m=m+1;
            hj = findobj(handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['D' num2str(i)]); % find optodes and their tags
            Hp=get(hj);
            Position=Hp.UserData';
            Tag=Hp.Tag;
            DisplayName=Hp.DisplayName;
            PointCloud{1,m}=hj;
            PointCloud{2,m}=Position';
            PointCloud{3,m}=Tag;
            PointCloud{4,m}=DisplayName;
            AllPtns=[AllPtns Position];
        end
        
        %%% sort Channels if exist
        for i=1:Num_Chn
            m=m+1;
            hj = findobj(handles.hj, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(i)]); % find optodes and their tags
            Hp=get(hj);
            Position=Hp.UserData';
            Tag=Hp.Tag;
            DisplayName=Hp.DisplayName;
            PointCloud{1,m}=hj;
            PointCloud{2,m}=Position';
            PointCloud{3,m}=Tag;
            PointCloud{4,m}=DisplayName;
        end
        
        %%%%%% find distances between the selected optode and other nearby optodes
        Li=10; %%% used to determine box limits to clip the mesh
        NS=20; %%% number of segments between the two points
        TH=60; %%%% distance threshold
        DS=dist(AllPtns',selectedPoint');
        DSm=sort(DS);
        
        %%% set parameters to plot arrows
        ArrSze=[DSm(1) DSm(end)]/100; %%% range of line width between optodes
        dtfVal(1,2)=0.1;
        
        Sel_pts=[]; %%% nearby optodes close than 60 mm
        for i=1:Num_Scr+Num_Det
            DL=dist(PointCloud{2,i},selectedPoint');
            if DL>0 && DL<TH
                if i<=Num_Scr
                    Sel_pts=[Sel_pts; i DL 1 0 0 0]; %%% source
                else
                    Sel_pts=[Sel_pts; i DL 2 0 0 0]; %%% detector
                end
                hold on
                roiPos=[selectedPoint; PointCloud{2,i}];
                inopt=struct('Channels','single','Whichchannel',[1 2],'ValLim',[0 1],'ArSzLt',ArrSze,'SpSzLt',[1 2]);
                
                [pathlength,midpoint,surface_points]=Compute_Geodesic_distance(selectedPoint,PointCloud{2,i},vertices,faces,NS,Li);
                Sel_pts(end,2)=pathlength;
                Sel_pts(end,4:6)=midpoint;
                drawdtfconngraph(dtfVal, roiPos, inopt);
                hki=findall(0,'Tag','Arrow');
                if ~isempty(hki)
                    if get(handles.Show_Arrows,'value')==0
                        set(hki,'Visible','off');
                    else
                        set(hki,'Visible','on');
                    end
                end
            end
            
        end
    end
    
    %%%% update channel positions related to the selected optode
    if Num_Chn~=0
        Tag_Sel_Pnt=X.DisplayName;
        for i=Num_Scr+Num_Det+1:size(PointCloud,2)
            Y=get(PointCloud{1,i}); %%%% channel handle
            Tag_Chn=Y.DisplayName; %%%% channel name
            Chn_Current_Position=Y.UserData; %%% current position of the selected channel
            if ~isempty(findstr(Tag_Chn,Tag_Sel_Pnt))
                Src_Det=regexp(Tag_Chn,'\d*','Match');
                SI=str2num(Src_Det{1,1});
                DI=str2num(Src_Det{1,2});
                %%% remove NIRS channel lines
                hm=findall(0,'Tag',['Lines_' Tag_Chn],'linewidth',3,'color','y');
                if ~isempty(hm)
                    delete(hm)
                end
                [pathlength,midpoint,surface_points]=Compute_Geodesic_distance(PointCloud{2,SI},PointCloud{2,DI+Num_Scr},vertices,faces,NS,Li);
                %%%% update the position of the source-detector midpoint (channel)
                set(PointCloud{1,i},'XData',Y.XData-Chn_Current_Position(1)+midpoint(1),'YData',Y.YData-Chn_Current_Position(2)+midpoint(2),'ZData',Y.ZData-Chn_Current_Position(3)+midpoint(3));
                set(PointCloud{1,i},'UserData',midpoint);
                for i1=1:size(surface_points,1)-1
                    hm=line([surface_points(i1,1) surface_points(i1+1,1)],[surface_points(i1,2) surface_points(i1+1,2)],[surface_points(i1,3) surface_points(i1+1,3)]);
                    set(hm,'Tag',['Lines_' Tag_Chn],'linewidth',3,'color','y');
                end
                %%%% update the position of the channel label
                hl = findobj(handles.figure1,'Type','text','String',Y.Tag); % find its label
                Xt=get(hl);
                Ds=dist(Nodes_Int,midpoint');
                L=find(Ds==min(abs(Ds)));
                b=Normal_Int(L(1),:); %%% new normal vector for the label
                V=midpoint-center; %%% vector connecting the head center to the electrode
                
                %%%% compute the angle between the channel normal vector and V
                A1 = cat(4,V(1),V(2),V(3)); % Combine the three components in the 4th dimension
                B1 = cat(4,b(1),b(2),b(3)); %
                C1 = cross(A1,B1,4); % Take the cross products
                ang = radtodeg(atan2(sqrt(dot(C1,C1,4)),dot(A1,B1,4)));
                if ang>90
                    b=b*-1;
                end
                set(hl,'Position',midpoint+Lij*b);
                set(hl,'UserData',b);
                h2 = findobj(gcf,'Facecolor','c'); % find channels
                if get(handles.Show_NIRS_Channels,'value')==0
                    set(h2,'Visible','off');
                else
                    set(h2,'Visible','on');
                end
                
                
            end
        end
    end
    
    %%% add annotations for distances
    m=0;
    Nt=40;
    Alltxt=[];
    if size(Sel_pts,1)>=1
        [i1,i2]=sort(Sel_pts(:,2));
        for i=1:size(Sel_pts,1)
            m=m+1;
            txt=[X.Tag '    to   ' PointCloud{3,Sel_pts(i2(i),1)} '  =  ' num2str(i1(i))];
            Alltxt=[Alltxt; txt blanks(Nt-length(txt))];
        end
        
    end
    set(handles.Interoptode_Distance,'string',Alltxt);
    
else
    errordlg('Please select an optode');
end
end
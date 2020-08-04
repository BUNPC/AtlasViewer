function AddOptode(handles,Si,txt,Label,Nodes_Int,Normal_Int)
% global SelectMode Grabbed Snap Points Weights Xi Degree Index


    %%%% pick a new position
    hi=findobj(gcf,'Tag','nd');

    %%%% pick a new position
    dcmObj = datacursormode(gcf);
    set(dcmObj,'DisplayStyle','window','SnapToDataVertex','on','Enable','on')
    
    % mouse click to pick a new position
    Point=[];
    while isempty(Point)
        pause(0.5)
        Point = getCursorInfo(dcmObj);
        if ~isempty(Point)
            selectedPoint = select3d(hi)'; 
            break
        end
    end
    datacursormode off
    
    
    %%%%% generate a sphere for electrodes
    r=5;
    [x,y,z] = sphere;
    
    %%%%% set parametyers for optode visualization
    AmbientStrength=0.2;
    DiffuseStrength=0.8;
    SpecularStrength=0.5;
    SpecularExponent=25;
 
    Ds=dist(Nodes_Int,selectedPoint');
    L=find(Ds==min(abs(Ds)));
    b=Normal_Int(L(1),:);
    Lij=5;
    
    
    if findstr(Label,'Src')
        handles.hj(Si,1) = surf(r*x+selectedPoint(1),r*y+selectedPoint(2),r*z+selectedPoint(3),'Facecolor','r','EdgeColor','none','Tag',txt,'DisplayName',Label);
        set(handles.hj(Si,1),'FaceLighting','phong','AmbientStrength',AmbientStrength,'DiffuseStrength',DiffuseStrength,'SpecularStrength',SpecularStrength,'SpecularExponent',SpecularExponent,...
            'BackFaceLighting','unlit','UserData',selectedPoint);
        handles.hj(Si,2)=text(selectedPoint(1)+Lij*b(1)+1,selectedPoint(2)+Lij*b(2)+1,selectedPoint(3)+Lij*b(3)+1,txt,'fontsize',12,'color','k','FontWeight','bold');
       set(handles.hj(Si,2),'UserData',b);
    
    elseif findstr(Label,'Det')
        handles.hj(Si,1) = surf(r*x+selectedPoint(1),r*y+selectedPoint(2),r*z+selectedPoint(3),'Facecolor','b','EdgeColor','none','Tag',txt,'DisplayName',Label);
        set(handles.hj(Si,1),'FaceLighting','phong','AmbientStrength',AmbientStrength,'DiffuseStrength',DiffuseStrength,'SpecularStrength',SpecularStrength,'SpecularExponent',SpecularExponent,...
            'BackFaceLighting','unlit','UserData',selectedPoint);
          handles.hj(Si,2)=text(selectedPoint(1)+Lij*b(1)+1,selectedPoint(2)+Lij*b(2)+1,selectedPoint(3)+Lij*b(3)+1,txt,'fontsize',12,'color','k','FontWeight','bold');
       set(handles.hj(Si,2),'UserData',b);
    end
    
 end

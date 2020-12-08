
warning off
center = mean(nodes);

%%%% plot head model and return its handle
skin   = [1,.75,.65];
cortex = [255 213 119]/255;
axis(handles.axes1);
handles.hi = plotmesh4probe(nodes, faces, 'facecolor',skin,'edgecolor','none','FaceAlpha',.5);

set(handles.hi,'Tag','nd');
set(handles.figure1,'color','w');
set(handles.axes1, 'Box','off','XTickLabel',[],'XTick',[],'YTickLabel',[],'YTick',[],'ZTickLabel',[],'ZTick',[],'XColor','w','YColor','w','ZColor','w');
lighting gouraud
material shiny

%%%% turn toolbars on
set(handles.figure1, 'menubar','none');
toolbarh = findall(handles.figure1,'Type','uitoolbar');
toolsh = allchild(toolbarh);

hold on
zoom(0.5);
delete(findall(handles.figure1,'Type','light'))
camlight('headlight');

%%%% change the position of camera light
handles.hm = rotate3d;
handles.hm.ActionPostCallback = @Change_Angle;
cameratoolbar(handles.figure1,'Show');
hold on

%%%%% generate a sphere for electrodes
r=4;
r1=2;
r2=1.5;
[x,y,z] = sphere;

%%%%% set parameters for optode visualization
AmbientStrength = 0.2;
DiffuseStrength = 0.8;
SpecularStrength = 0.5;
SpecularExponent = 25;

%%%% keep vertexs above Z=0 plane
Nodes_Int = nodes;
Normal_Int = normals';


S = 0; %%% source counter
D = 0; %%% detector counter
C = 0; %%% channel counter

ml = handles.probe.ml;
Lij = 1; %%% parameter used to visualize optode labels
Chn_txt = [];
DLtxt = 30;
F=[];
for i=1:size(Chspos,1)
    if Chspos(i,4)==3 %%%% compute inter-optode midpoints (NIRS channles)
        C = C+1;
        Li = 10; %%% used to determine box limits to clip the mesh
        NS = 20; %%% number of segments between the two points
        Src_Pos = Chspos(ml(C,1),1:3);
        Det_Pos = Chspos(ml(C,2)+Num_Scr,1:3);
        [pathlength,midpoint] = Compute_Geodesic_distance(Src_Pos,Det_Pos,nodes,faces,NS,Li);
        Chspos(i,1:3) = midpoint;
    end
    Ds = dist(Nodes_Int,Chspos(i,1:3)');
    L = find(Ds==min(abs(Ds)));
    Chn_Vn = double(Normal_Int(:,L(1))); %%% channel: normal vector
    Chspos(i,1:3) = Nodes_Int(L(1),1:3);
    V = Chspos(i,1:3)-center; %%% vector connecting the head center to the electrode
    
    %%%% compute the angle between the channel normal vector and V
    A1 = cat(4,V(1),V(2),V(3)); % Combine the three components in the 4th dimension
    B1 = cat(4,Chn_Vn(1),Chn_Vn(2),Chn_Vn(3)); %
    C1 = cross(A1,B1,4); % Take the cross products
    ang = radtodeg(atan2(sqrt(dot(C1,C1,4)),dot(A1,B1,4)));
    if ang>90
        Chn_Vn = Chn_Vn*-1;
    end
    if Chspos(i,4)==1
        S=S+1;
        Label = ['Src ' num2str(S)];
        handles.hj(i,1) = surf(r*x+Chspos(i,1),r*y+Chspos(i,2),r*z+Chspos(i,3),'Facecolor','r','EdgeColor','none','Tag',['S' num2str(S)],'DisplayName',Label);
        set(handles.hj(i,1),'FaceLighting','phong','AmbientStrength',AmbientStrength,'DiffuseStrength',DiffuseStrength,'SpecularStrength',SpecularStrength,'SpecularExponent',SpecularExponent,...
            'BackFaceLighting','unlit','UserData',Chspos(i,1:3));
        handles.hj(i,2) = text(Chspos(i,1)+Lij*Chn_Vn(1),Chspos(i,2)+Lij*Chn_Vn(2),Chspos(i,3)+Lij*Chn_Vn(3),['S' num2str(S)],'fontsize',12,'color','k','FontWeight','bold');
        set(handles.hj(i,2),'UserData',Chspos(i,1:3));
    elseif Chspos(i,4)==2
        D=D+1;
        Label = ['Det ' num2str(D)];
        handles.hj(i,1) = surf(r*x+Chspos(i,1),r*y+Chspos(i,2),r*z+Chspos(i,3),'Facecolor','b','EdgeColor','none','Tag',['D' num2str(D)],'DisplayName',Label);
        set(handles.hj(i,1),'FaceLighting','phong','AmbientStrength',AmbientStrength,'DiffuseStrength',DiffuseStrength,'SpecularStrength',SpecularStrength,'SpecularExponent',SpecularExponent,...
            'BackFaceLighting','unlit','UserData',Chspos(i,1:3));
        handles.hj(i,2) = text(Chspos(i,1)+Lij*Chn_Vn(1),Chspos(i,2)+Lij*Chn_Vn(2),Chspos(i,3)+Lij*Chn_Vn(3),['D' num2str(D)],'fontsize',12,'color','k','FontWeight','bold');
        set(handles.hj(i,2),'UserData',Chspos(i,1:3));
    elseif Chspos(i,4)==3 %%%% NIRS channels
        Label = ['Src ' num2str(ml(C,1)) ' - Det ' num2str(ml(C,2))];
        Li = 10; %%% used to determine box limits to clip the mesh
        NS = 20; %%% number of segments between the two points
        pt1 = Chspos(ml(C,1),1:3);
        pt2 = Chspos(ml(C,2)+Num_Scr,1:3);
        [pathlength,midpoint,surface_points] = Compute_Geodesic_distance(pt1,pt2,nodes,faces,NS,Li);
        for i1=1:size(surface_points,1)-1
            hm = line([surface_points(i1,1) surface_points(i1+1,1)],[surface_points(i1,2) surface_points(i1+1,2)],[surface_points(i1,3) surface_points(i1+1,3)]);
            set(hm,'Tag',['Lines_' Label],'linewidth',3,'color','y');
        end
        Chspos(i,1:3) = midpoint;
        
        handles.hj(i,1) = surf(r2*x+Chspos(i,1),r2*y+Chspos(i,2),r2*z+Chspos(i,3),'Facecolor','c','EdgeColor','none','Tag',['Ch' num2str(C)],'DisplayName',Label);
        set(handles.hj(i,1),'FaceLighting','phong','AmbientStrength',AmbientStrength,'DiffuseStrength',DiffuseStrength,'SpecularStrength',SpecularStrength,'SpecularExponent',SpecularExponent,...
            'BackFaceLighting','unlit','UserData',Chspos(i,1:3));
        handles.hj(i,2) = text(Chspos(i,1)+Lij*Chn_Vn(1),Chspos(i,2)+Lij*Chn_Vn(2),Chspos(i,3)+Lij*Chn_Vn(3),['Ch' num2str(C)],'fontsize',12,'color','k','FontWeight','bold','FontAngle','italic');
        
        if get(handles.Show_NIRS_Channels,'value')==0
            set(handles.hj(i,1),'Visible','off');
            set(handles.hj(i,2),'Visible','off');
        else
            set(handles.hj(i,1),'Visible','on');
            set(handles.hj(i,2),'Visible','on');
        end
        
        set(handles.hj(i,2),'UserData',Chn_Vn);
        Chtxt = [Label '    (Ch ' num2str(C) ')'];
        Chn_txt = [Chn_txt; Chtxt blanks(DLtxt-length(Chtxt))];
        if C==size(ml,1)
            set(handles.Source_Detector_Pairs,'String',Chn_txt);
        end
    end
    hold on
end

%%%% EEG electrodes
if size('handles.refpts',2)>1
    elec = [];
    for i=1:size(handles.refpts,1)
        Elc = handles.refpts{i,1}(:,axes_order);
        elec = [elec ; Elc];
        elec_labels{1,i} = handles.refpts{i,2};
    end
    
    for i=1:size(elec,1)
        Ds = dist(Nodes_Int(:,1:3),elec(i,1:3)');
        L = find(Ds==min(abs(Ds)));
        elec_Vn = double(Normal_Int(:,L(1)));
        elec(i,1:3) = Nodes_Int(L(1),1:3);
        V = elec(i,1:3)-center; %%% vector connecting the head center to the electrode
        
        %%%% compute the angle between the channel normal vector and V
        A1 = cat(4,V(1),V(2),V(3)); % Combine the three components in the 4th dimension
        B1 = cat(4,elec_Vn(1),elec_Vn(2),elec_Vn(3)); %
        C1 = cross(A1,B1,4); % Take the cross products.
        ang = radtodeg(atan2(sqrt(dot(C1,C1,4)),dot(A1,B1,4)));
        if ang>90
            elec_Vn = elec_Vn*-1;
        end
        handles.he(i,1) = surf(r1*x+elec(i,1),r1*y+elec(i,2),r1*z+elec(i,3),'Facecolor','g','EdgeColor','none','Tag',['ELC' num2str(i)],'DisplayName',elec_labels{i});
        set(handles.he(i,1),'FaceLighting','phong','AmbientStrength',AmbientStrength,'DiffuseStrength',DiffuseStrength,'SpecularStrength',SpecularStrength,'SpecularExponent',SpecularExponent,...
            'BackFaceLighting','unlit','UserData',elec(i,1:3),'Visible','off');
        handles.he(i,2) = text(elec(i,1)+Lij*elec_Vn(1),elec(i,2)+Lij*elec_Vn(2),elec(i,3)+Lij*elec_Vn(3),elec_labels{i},'fontsize',8,'color','k','FontWeight','bold');
        set(handles.he(i,2),'UserData',elec_Vn,'Visible','off');
        hold on
    end
end

set(handles.figure1, 'WindowButtonDownFcn', {@ManualCorrection_Distance,handles,Num_Scr,Num_Det,Num_Chn,Normal_Int'});








function [New_Probe]=RemoveOptode(New_Probe)
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
    
AllPtns=[];
Indx=[];
%%% sort sources
for i=1:New_Probe.Num_Src
    hj = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['S' num2str(i)]); % find optodes and their tags
    if ~isempty(hj)
        H=get(hj);
        Position=H.UserData';
        AllPtns=[AllPtns Position];
        Indx=[Indx; i 1 1]; %%% source number, source status (1: exist, 0: doesn't exist, optode type (1: source, 2: detector, 3: channel)
    else
        AllPtns=[AllPtns  zeros(3,1)];
        Indx=[Indx; i 0 1];
    end
end

%%% sort Detectors
for i=1:New_Probe.Num_Det
    hj = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['D' num2str(i)]); % find optodes and their tags
    if ~isempty(hj)
        H=get(hj);
        Position=H.UserData';
        AllPtns=[AllPtns Position];
        Indx=[Indx; i 1 2];
    else
        AllPtns=[AllPtns  zeros(3,1)];
        Indx=[Indx; i 0 2];
    end
end

%%% sort Channels
for i=1:New_Probe.Num_Chn
    hj = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(i)]); % find optodes and their tags
    if ~isempty(hj)
        H=get(hj);
        Position=H.UserData';
        AllPtns=[AllPtns Position];
        Indx=[Indx; i 1 3];
    else
        AllPtns=[AllPtns zeros(3,1)];
        Indx=[Indx; i 0 3];
    end
end

Ds=dist(AllPtns',selectedPoint');
L=find(Ds==min(abs(Ds)));

pointCloudIndex=L(1);
Op_type=Indx(pointCloudIndex,3);
if Op_type==1  %%% source
    h = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['S' num2str(Indx(pointCloudIndex,1))]); % find optodes and their tags
    Name=get(h,'Tag');
    for i=1:New_Probe.Num_Chn
        hj = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(i)]); % find optodes and their tags
        if ~isempty(hj)
            X=get(hj);
            if ~isempty((findstr(X.DisplayName,['Src ' num2str(Indx(pointCloudIndex,1))])))
                htc=findobj(gca,'Type','text','string',X.Tag);
                delete(hj);
                delete(htc);
                New_Probe.Channel{i,1}='';
                New_Probe.Channel{i,2}=0;
                New_Probe.Channel{i,3}='';
                New_Probe.Channel{i,4}='';
            end
        end
    end
    ht=findobj(gca,'Type','text','string',Name);
    delete(h);
    delete(ht);
    New_Probe.Source{Indx(pointCloudIndex,1),1}='';
    New_Probe.Source{Indx(pointCloudIndex,1),2}=0;
    
elseif Op_type==2 %%% detector
    h = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['D' num2str(Indx(pointCloudIndex,1))]); % find optodes and their tags
    Name=get(h,'Tag');
    for i=1:New_Probe.Num_Chn
        hj = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(i)]); % find optodes and their tags
        if ~isempty(hj)
            X=get(hj);
            if ~isempty((findstr(X.DisplayName,['Det ' num2str(Indx(pointCloudIndex,1))])))
                htc=findobj(gca,'Type','text','string',X.Tag);
                delete(hj);
                delete(htc);
                New_Probe.Channel{i,1}='';
                New_Probe.Channel{i,2}=0;
                New_Probe.Channel{i,3}='';
                New_Probe.Channel{i,4}='';
            end
        end
    end
    ht=findobj(gca,'Type','text','string',Name);
    delete(h);
    delete(ht);
    New_Probe.Detector{Indx(pointCloudIndex,1),1}='';
    New_Probe.Detector{Indx(pointCloudIndex,1),2}=0;
elseif Op_type==3 %%% channel
    h = findobj(gca, 'AmbientStrength',.2,'DiffuseStrength',.8,'SpecularStrength',.5,'Tag',['Ch' num2str(Indx(pointCloudIndex,1))]); % find optodes and their tags
    Name=get(h,'Tag');
    ht=findobj(gca,'Type','text','string',Name);
    delete(h);
    delete(ht);
    New_Probe.Channel{Indx(pointCloudIndex,1),1}='';
    New_Probe.Channel{Indx(pointCloudIndex,1),2}=0;
    New_Probe.Channel{Indx(pointCloudIndex,1),3}='';
    New_Probe.Channel{Indx(pointCloudIndex,1),4}='';
end


% if ~isempty(strfind(Name,'S'))
%     Nm=get(h,'DisplayName');
%     for i=1:size(AH,1)
%         Tag=get(AH(i),'DisplayName');
%         if ~isempty(strfind(Tag,Nm))
%                 if ~isempty(strfind(Tag,'D'))
%                     C=C-1;
%                 else
%                     ht=findobj(gca,'Type','text','string',Name);
%                     delete(AH(i));
%                 delete(ht);
%                     S=S-1;
%                 end
%         end
%     end
% elseif ~isempty(strfind(Name,'D'))
%     Nm=get(h,'DisplayName');
%     for i=1:size(AH,1)
%         Tag=get(AH(i),'DisplayName');
%         if ~isempty(strfind(Tag,Nm))
%             if ~isempty(strfind(Tag,'S'))
%                ht=findobj(gca,'Type','text','string',Name);
%                delete(AH(i));
%                 delete(ht);
%                 C=C-1;
%             else
%                 ht=findobj(gca,'Type','text','string',Name);
%                 delete(AH(i));
%                 delete(ht);
%                 D=D-1;
%             end
%         end
%     end
% elseif ~isempty(strfind(Name,'Ch'))
%     ht=findobj(gca,'Type','text','string',Name);
%     delete(ht);
%     delete(h);
%     C=C-1;
% end
%
% end
% % Construct a questdlg with three options
% choice = questdlg('Would you like a dessert?', ...
% 	'Dessert Menu', ...
% 	'Ice cream','Cake','No thank you','No thank you');
% % Handle response
% switch choice
%     case 'Ice cream'
%         disp([choice ' coming right up.'])
%         dessert = 1;
%     case 'Cake'
%         disp([choice ' coming right up.'])
%         dessert = 2;
%     case 'No thank you'
%         disp('I''ll bring you your check.')
%         dessert = 0;
% end
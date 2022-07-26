function displayProbeOnUnitCircle(probe, optode_display_type)

% This code developed based on below CSD toolbox-
% https://psychophysiology.cpmc.columbia.edu/software/csdtoolbox/tutorial.html

SD = convertProbe2SD(probe);

% read landmarks labels to display
E = textread('E31.asc','%s');

% Get 10-5 ref pts positions on unit sphere.
sphere = probe.registration.refpts.eeg_system.sphere;

% get postions of landmarks to display
refpts_idx =  ismember(lower(sphere.label), lower(E) );
refpts_label = sphere.label(refpts_idx);
refpts_theta =  sphere.theta(refpts_idx);
refpts_phi = 90 - sphere.phi(refpts_idx); 
refpts_theta = (2 * pi * refpts_theta) / 360; 
refpts_phi = (2 * pi * refpts_phi) / 360;
[x,y] = pol2cart(refpts_theta, refpts_phi);      
xy = [x y];
norm_factor = max(max(xy));
xy = xy/norm_factor;  

% get Nose position
nose_pos_idx = strcmpi(refpts_label,'Nose');
nose_pos = xy(nose_pos_idx,:);

% Generate figure
figure
t = 0:pi/100:2*pi; 
head = [sin(t) ; cos(t)]';
axis image
set(gcf,'color','w');
axis off
line(head(:,1),head(:,2),'Color','k','LineWidth',1); 
hold on
landmarks_color = [0.4 0.4 0.4];
for u = 1:length(refpts_label)
if ~strcmpi(refpts_label(u),'Nose')
    text(xy(u,1),xy(u,2), ...
         refpts_label(u), ...
          'FontSize',8, ...
          'color',landmarks_color, ...
          'VerticalAlignment','middle', ...
          'HorizontalAlignment','center');
else
    text(xy(u,1),xy(u,2)-0.075, ...
         refpts_label(u), ...
          'FontSize',8, ...
          'color',landmarks_color, ...
          'VerticalAlignment','middle', ...
          'HorizontalAlignment','center');
end
end
if strcmpi(optode_display_type,'circles')
    plot(SD.SrcPos2D(:,1), SD.SrcPos2D(:,2), 'or','MarkerSize',4, 'MarkerFaceColor','r');
    plot(SD.DetPos2D(:,1), SD.DetPos2D(:,2), 'ob','MarkerSize',4, 'MarkerFaceColor','b');
elseif strcmpi(optode_display_type,'numbers')
    for u = 1:size(SD.SrcPos2D,1)
        text(SD.SrcPos2D(u,1),SD.SrcPos2D(u,2), ...
         num2str(u), ...
          'FontSize',10, ...
          'FontWeight','bold', ...
          'color','r', ...
          'VerticalAlignment','middle', ...
          'HorizontalAlignment','center');
    end
    for u = 1:size(SD.DetPos2D,1)
        text(SD.DetPos2D(u,1),SD.DetPos2D(u,2), ...
         num2str(u), ...
          'FontSize',10, ...
          'FontWeight','bold', ...
          'color','b', ...
          'VerticalAlignment','middle', ...
          'HorizontalAlignment','center');
    end
end
plot(nose_pos(1),nose_pos(2),'k^','MarkerSize',15,'LineWidth',1, 'color',landmarks_color);
hold off
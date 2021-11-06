function SD = updateProbe2DcircularPts(probe, SD)

if isempty(SD.Landmarks)
    return
end

% Get 10-5 ref pts positions on unit sphere.
sphere = probe.registration.refpts.eeg_system.sphere;
if isempty(sphere.label)
    return
end

% ref pt labels used for affine transformation
refpts_labels = {'T7','T8','Oz','Fpz','Cz','C3','C4','Pz','Fz'};

% get positions for refpts_labels from both sphere and probe ref pts
for u = 1:length(refpts_labels)
    label = refpts_labels{u};

    idx = ismember(SD.Landmarks.labels, label);
    if isempty(idx)
        return
    end
    probe_refps_pos(u,:) = SD.Landmarks.pos(idx,:);
    idx = ismember(sphere.label, label);
    sphere_refpts_pos(u,:) = [sphere.xc(idx) sphere.yc(idx) sphere.zc(idx)];
end

% get affine transformation
% probe_refps*T = sphere_refpts
probe_refps_pos = [probe_refps_pos ones(size(probe_refps_pos,1),1)];
T = probe_refps_pos\sphere_refpts_pos;

% tranform optode positions onto unit sphere.
% opt_pos = probe.optpos_reg;
% opt_pos = [opt_pos ones(size(opt_pos,1),1)];
% sphere_opt_pos = opt_pos*T;
% sphere_opt_pos_norm = sqrt(sum(sphere_opt_pos.^2,2));
% sphere_opt_pos = sphere_opt_pos./sphere_opt_pos_norm ;
%%
% get 2D circular refpts for current selecetd reference point system
probe_refpts_idx =  ismember(sphere.label, SD.Landmarks.labels);

% refpts_2D.pos = [sphere_xc(probe_refpts_idx) sphere_yc(probe_refpts_idx) sphere_zc(probe_refpts_idx)];
refpts_2D.label = sphere.label(probe_refpts_idx);
%%
refpts_theta =  sphere.theta(probe_refpts_idx);
refpts_phi = 90 - sphere.phi(probe_refpts_idx); % elevation angle from top axis

refpts_theta = (2 * pi * refpts_theta) / 360; % convert to radians
refpts_phi = (2 * pi * refpts_phi) / 360;
[x,y] = pol2cart(refpts_theta, refpts_phi);      % get plane coordinates
xy = [x y];

%%
norm_factor = max(max(xy));
xy = xy/norm_factor;               % set maximum to unit length
xy = xy/2 + 0.5;                    % adjust to range 0-1
refpts_2D.pos = xy;
SD.Landmarks2D = refpts_2D;

%%
if isfield(SD,'SrcPos3D') & ~isempty(SD.SrcPos3D)
    SD.SrcPos2D = convert_optodepos_to_circlular_2D_pos(SD.SrcPos3D, T, norm_factor);
end
if isfield(SD,'DetPos3D') & ~isempty(SD.DetPos3D)
    SD.DetPos2D = convert_optodepos_to_circlular_2D_pos(SD.DetPos3D, T, norm_factor);
end
if isfield(SD,'DummyPos3D') & ~isempty(SD.DummyPos3D)
    SD.DummyPos2D = convert_optodepos_to_circlular_2D_pos(SD.DummyPos3D, T, norm_factor);
end

% -------------------------------------------------------------------------------
function xy = convert_optodepos_to_circlular_2D_pos(pos, T, norm_factor)
pos = [pos ones(size(pos,1),1)];
pos_unit_sphere = pos*T;
pos_unit_sphere_norm = sqrt(sum(pos_unit_sphere.^2,2));
pos_unit_sphere = pos_unit_sphere./pos_unit_sphere_norm ;

[azimuth,elevation,r] = cart2sph(pos_unit_sphere(:,1),pos_unit_sphere(:,2),pos_unit_sphere(:,3));
elevation = pi/2-elevation;
[x,y] = pol2cart(azimuth,elevation);      % get plane coordinates
xy = [x y];
xy = xy/norm_factor;               % set maximum to unit length
xy = xy/2 + 0.5;


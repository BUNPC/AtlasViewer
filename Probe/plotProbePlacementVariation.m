function plotProbePlacementVariation()
% Selection 1: Inter-subject variability analysis:
%   Plots multiple subject probe geometries on a common atlas volume
%   Plots mean optode locations and their standard deviations
% Selection 2: Probe fabrication error analysis:
%   Plots original source-detector geometries versus digitized probe(s)
%   Plots original optode locations and the digitized mean error distribution

% NOTE: There is no need to have a special external file (in this case 
% atlasViewer_SDdesign.mat) where the design probe is stored and needs to be 
% loaded. We really should use the existing AV framework to do this. 
% Everything in AV exists in the context of a subject and it's associated 
% folder. That subject can also be a group as well if it's folder has AV 
% compatible subject folders under it. So the design probe IS the probe of 
% whichever subject (or in this case, group subject) is trying to perform
% this operation, i.e. generating the probe variability stats for it's subject 
% probes. Therefore, the design probe is simply, the current subject's probe, 
% i.e., atlasViewer.probe. This probe was either imported as you would any 
% other probe or loaded at AV startup through atlasViewer.mat both within 
% the realm normal AV operations and AV design. -- JD 10/24/2018

global atlasViewer
global tableData
global hTbl

tableData = [];
hTbl = [];
f  = atlasViewer.headsurf.mesh.faces;
v  = atlasViewer.headsurf.mesh.vertices;
fp = atlasViewer.pialsurf.mesh.faces;
vp = atlasViewer.pialsurf.mesh.vertices;

% Sanity check that the design probe exists. If not we have 
% nothing to work with. 
if isempty(atlasViewer.probe.optpos_reg)
    MenuBox('Design probe for this subject does not exist or is not registered to head','OK');
    return;
end

% Find atlasViewer.mat files located one subdirectory deep.
[subjDirs, errmsg] = findSubjDirs();
nSubj = length(subjDirs);

% Make sure we have at least 2 subjects
if errCheck(subjDirs, errmsg) < 0
    return;
end

if leftRightFlipped(atlasViewer.refpts)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

wd = cd();
pathnm = uigetdir(wd,'Select Group Root Folder containing the Subject Folders');
if pathnm == 0
    return
end
cd(pathnm)

% Define the distance threshold that isolates short separation channels
ssThresh = 15; % millimeters

userSelection = MenuBox('Analysis Type',{'Inter-subject variability','Probe fabrication error'});

tblFigPos = [.20,.15,.35,.20];

% Display figures for head displays
hFigHeadDisp = getHeadFigures(v, f, vp, fp, axes_order);

if (userSelection == 2)
        
    % Head Surface
    fN = trisurfnorm(v, f); % This function is provided in a separate file

    set(hFigHeadDisp(1), 'name','SD Layout (Black) and Digitized Probe Positions');
    figure(hFigHeadDisp(1));
    
    % Original Circle for Patches
    temp = 1:1:21;
    radius = 2.5;
    x = radius * cos(2 * pi * temp(:) / size(temp, 2));
    y = radius * sin(2 * pi * temp(:) / size(temp, 2));
    z(1:size(temp, 2)) = 0;
    circle1 = [x(:), y(:), z(:)];
    circ1N = [0 0 1]; % Normal to the plane of circle 1
    circle2 = circle1; % Create a second circle variable to be modified each loop of s (below)

    % Define the colors to be used for the optodes
    colors1 = colormap;
    for i = 1:1:nSubj
        patchColor(i,:) = colors1(1+round(63*i/nSubj),:);
    end

    % Translate each subject's optode positions onto a common atlas and plot
    rotEig(1:3,1:3,1:nSubj) = 0;
    optN = 100; % Temporary value in case the following loop doesn't run
    for s=1:nSubj
        % Load Subject Data, Transform Probe, Plot Circles Normal to Surface
        sub = load(subjDirs{s}, '-mat');
        p = sub.probe.optpos_reg; % Original registered optode positions
        p(:, 4) = 1;
        T = sub.headvol.T_2mc; % Translation matrix to individual subject space
        Ti(1:4, 1:4) = inv(T(1:4, 1:4)); % Inverse produces translation to common atlas space

        % Search for optodes that are closer together than the ssThresh and exclude them
        useList(1:size(p, 1)) = 1;
        for i = 1:1:size(p, 1)
            for j = 1:1:size(p, 1)
                if (sqrt((p(i, 1) - p(j, 1))^2 + (p(i, 2) - p(j, 2))^2 ...
                    + (p(i, 3) - p(j, 3))^2) < ssThresh)
                    % The following statements assume sources are listed 
                    % before detectors and therefore the optode to exclude 
                    % has the higher number
                    if (i > j)
                        useList(i) = 0;
                    end
                    if (j > i)
                        useList(j) = 0;
                    end
                end
            end
        end
        optN = sum(useList(:));
        p2(1:optN,1:4) = 0;
        j = 1;
        for i=1:1:size(p, 1)
            if (useList(i) ~= 0) % Only entries in the useList are carried to subsequent steps
                p2(j, 1:4) = transpose(Ti * transpose(p(i, 1:4))); % New optode positions in common space
                j = j + 1;
            end
        end

        p2n(1:optN, 1:3) = 0; % Create an array to store the normal vector from the common atlas surface at each optode position
        for i=1:1:optN
            vmin = 1e99; vidx = 0;
            for j = 1:1:size(v, 1)
                foo = sqrt((p2(i,1)-v(j,1))^2 + (p2(i,2)-v(j,2))^2 + (p2(i,3)-v(j,3))^2); % distance from optode to vertex
                if (foo < vmin) % Search for vertex with the minimum distance from the optode
                    vmin = foo;
                    vidx = j;
                end
            end
            [lst, foo] = find(f==vidx); % Using the nearest vertex, find the matching faces
            for j = 1:1:size(lst, 1)
                p2n(i, :) = p2n(i, :) + fN(lst(j), :); % Sum the normal vectors for all matching faces
            end
            p2n(i, :) = p2n(i, :) / size(lst, 1); % Divide by the number of faces to find the average normal vector
            p2T = vrrotvec2mat_copy(vrrotvec_copy(circ1N, p2n(i, :))); % Create a rotation matrix using the original circle normal and the average normal vector for the optode location
            for j = 1:1:size(circle1, 1)
                circle2(j, :) = transpose(p2T * transpose(circle1(j, :))) + p2(i, 1:3); % Rotate and translate the original circle shape into the optode plane and position
            end
            patch(circle2(:, axes_order(1)), circle2(:, axes_order(2)), circle2(:, axes_order(3)), patchColor(s,:)); % Creates a patch using the optode circle on the head volume
        end

        [foo, bar] = eig(sub.headvol.T_2mc(1:3,1:3)); % Calculate the eigenvalues of the rotation matrix from subject space to common atlas space
        rotEig(1:3,1:3,s) = abs(bar); % Store the absolute value of the rotation matrix eigenvalues
        p2all(:,1:4,s) = p2; % Store the subject's translated optode locations for group plot
    end

    % Small Circle for Probe  Patches
    temp = 1:1:21;
    radius = 1;
    x = radius * cos(2 * pi * temp(:) / size(temp, 2));
    y = radius * sin(2 * pi * temp(:) / size(temp, 2));
    z(1:size(temp, 2)) = 0;
    circle1 = [x(:), y(:), z(:)];
    circ1N = [0 0 1]; % Normal to the plane of circle 1
    circle2 = circle1; % Create a second circle variable to be modified each loop of s (below)
    
    % Plot the original probe design (black)
    p2n(1:optN, 1:3) = 0; % Create an array to store the normal vector from the common atlas surface at each optode position
    p2 = atlasViewer.probe.optpos_reg; % Original probe design
    for i=1:1:optN
        vmin = 1e99; vidx = 0;
        for j = 1:1:size(v, 1)
            foo = sqrt((p2(i,1)-v(j,1))^2 + (p2(i,2)-v(j,2))^2 + (p2(i,3)-v(j,3))^2); % distance from optode to vertex
            if (foo < vmin) % Search for vertex with the minimum distance from the optode
                vmin = foo;
                vidx = j;
            end
        end
        [lst, foo] = find(f==vidx); % Using the nearest vertex, find the matching faces
        for j = 1:1:size(lst, 1)
            p2n(i, :) = p2n(i, :) + fN(lst(j), :); % Sum the normal vectors for all matching faces
        end
        p2n(i, :) = p2n(i, :) / size(lst, 1); % Divide by the number of faces to find the average normal vector
        p2T = vrrotvec2mat_copy(vrrotvec_copy(circ1N, p2n(i, :))); % Create a rotation matrix using the original circle normal and the average normal vector for the optode location
        for j = 1:1:size(circle1, 1)
            circle2(j, :) = transpose(p2T * transpose(circle1(j, :))) + p2(i, 1:3); % Rotate and translate the original circle shape into the optode plane and position
        end
        patch(circle2(:, axes_order(1)), circle2(:, axes_order(2)), circle2(:, axes_order(3)), 'k'); % Creates a patch using the optode circle on the head volume
    end

    % Group-Level Analysis
    scale(1) = mean(rotEig(1,1,:)); % Find the average scaling factor in the X-direction
    scale(2) = mean(rotEig(2,2,:)); % Find the average scaling factor in the Y-direction
    scale(3) = mean(rotEig(3,3,:)); % Find the average scaling factor in the Z-direction

    p2probeDesign(1:optN,1:3) = 0;
    p2error(1:optN,1:nSubj) = 0;
    p2vec(1:optN,1:3,1:nSubj) = 0;
    p2meanError(1:optN) = 0;
    
    for i = 1:1:optN
        for j = 1:1:3
            p2probeDesign(i,j) = atlasViewer.probe.optpos_reg(i,j); % Original probe design
        end
        for j = 1:1:nSubj
            p2error(i,j) = sqrt((((p2all(i,1,j)-p2probeDesign(i,1))) / scale(1))^2 + ...
                (((p2all(i,2,j)-p2probeDesign(i,2))) / scale(2))^2 + ...
                (((p2all(i,3,j)-p2probeDesign(i,3))) / scale(3))^2); % Calculate the Euclidean position error and correct for scaling
            p2vec(i,1,j) = (p2all(i,1,j)-p2probeDesign(i,1)) / scale(1);
            p2vec(i,2,j) = (p2all(i,2,j)-p2probeDesign(i,2)) / scale(2);
            p2vec(i,3,j) = (p2all(i,3,j)-p2probeDesign(i,3)) / scale(3);
        end
        p2meanError(i) = mean(p2error(i,:)); % Mean Error, scaled to millimeters
    end

    % Plot a second head and pial surface for group-level results
    set(hFigHeadDisp(2), 'name','Mean Geometric Error from Original SD Locations (mm)');
    figure(hFigHeadDisp(2));
    
    % Create a color bar that displays the standard deviation value associated with each color
    setColorBar(p2meanError);
                        
    % Plot the original probe design (black)
    p2n(1:optN, 1:3) = 0; % Create an array to store the normal vector from the common atlas surface at each optode position
    p2 = atlasViewer.probe.optpos_reg; % Original probe design
    for i=1:1:optN
        vmin = 1e99; vidx = 0;
        for j = 1:1:size(v, 1)
            foo = sqrt((p2(i,1)-v(j,1))^2 + (p2(i,2)-v(j,2))^2 + (p2(i,3)-v(j,3))^2); % distance from optode to vertex
            if (foo < vmin) % Search for vertex with the minimum distance from the optode
                vmin = foo;
                vidx = j;
            end
        end
        [lst, foo] = find(f==vidx); % Using the nearest vertex, find the matching faces
        for j = 1:1:size(lst, 1)
            p2n(i, :) = p2n(i, :) + fN(lst(j), :); % Sum the normal vectors for all matching faces
        end
        p2n(i, :) = p2n(i, :) / size(lst, 1); % Divide by the number of faces to find the average normal vector
        p2T = vrrotvec2mat_copy(vrrotvec_copy(circ1N, p2n(i, :))); % Create a rotation matrix using the original circle normal and the average normal vector for the optode location
        for j = 1:1:size(circle1, 1)
            circle2(j, :) = transpose(p2T * transpose(circle1(j, :))) + p2(i, 1:3); % Rotate and translate the original circle shape into the optode plane and position
        end
        patch(circle2(:, axes_order(1)), circle2(:, axes_order(2)), circle2(:, axes_order(3)), 'k'); % Creates a patch using the optode circle on the head volume
    end
    
    p2mean(1:optN,1:3) = 0;
    for i = 1:1:optN
        for j = 1:1:3
            p2mean(i,j) = mean(p2all(i,j,:)); % Calculate the mean optode locations across subjects
        end
    end
    
    % Plot patches at mean of each probe location
    colors = colormap; % Create a matrix using the current color map for pulling color associated with each value
    p2n(1:optN, 1:3) = 0;
    for i=1:1:optN
        % Find the nearest vertex to each group-mean optode position
        vmin = 1e99; vidx = 0;
        for j = 1:1:size(v, 1)
            foo = sqrt((p2mean(i,1)-v(j,1))^2 + (p2mean(i,2)-v(j,2))^2 + (p2mean(i,3)-v(j,3))^2);
            if (foo < vmin)
                vmin = foo;
                vidx = j;
            end
        end
        [lst, foo] = find(f==vidx);
        % Find the normal vector for each group-mean optode position
        for j = 1:1:size(lst, 1)
            p2n(i, :) = p2n(i, :) + fN(lst(j), :);
        end
        p2n(i, :) = p2n(i, :) / size(lst, 1);
        
        p2proj(1:optN,1:3,1:nSubj) = 0;
        for j=1:1:nSubj
            p2projT = vrrotvec2mat_copy(vrrotvec_copy(p2n(i, :), [0 0 1]));
            p2proj(i,:,j) = transpose(p2projT * transpose(cross(p2n(i,:), cross(p2vec(i,:,j), p2n(i,:)))));
        end
        
        % Radius-defined ellipse for patches
        temp = 1:1:21;
        radiusX = std(p2proj(i,1,:));
        radiusY = std(p2proj(i,2,:));
        x = radiusX * cos(2 * pi * temp(:) / size(temp, 2));
        y = radiusY * sin(2 * pi * temp(:) / size(temp, 2));
        z(1:size(temp, 2)) = 0;
        circle1 = [x(:), y(:), z(:)];
        circ1N = [0 0 1];
        circle2 = circle1; % Create new variable with same size

        p2T = vrrotvec2mat_copy(vrrotvec_copy(circ1N, p2n(i, :)));
        for j = 1:1:size(circle1, 1)
            circle2(j, :) = transpose(p2T * transpose(circle1(j, :))) + p2mean(i, 1:3);
        end
        color = 1+round(63*(p2meanError(i)-min(p2meanError))/(max(p2meanError)-min(p2meanError))); % This picks the most appropriate of the 64 colormap colors
        patch(circle2(:, axes_order(1)), circle2(:, axes_order(2)), circle2(:, axes_order(3)), ...
            [colors(color, 1) colors(color, 2) colors(color, 3)]); % Creates a patch using the colormap color and group-mean optode circle
    end
    
    % Create UI Table with Error Information
    hFigTbl = figure('name', 'Probe Creation Error', 'units','normalized','position', tblFigPos);
    hold on
    tableData(:, 1:3) = p2(1:optN, 1:3);
    tableData(:, 4:6) = p2mean(1:optN, 1:3);
    tableData(:, 7) = transpose(p2meanError);
    hTbl = uitable(hFigTbl, 'Data', tableData, 'ColumnName', {'Design X', ...
                   'Design Y', 'Design Z', 'Mean X', 'Mean Y', 'Mean Z', ...
                   'Mean Geometric Error (mm)'}, 'units','normalized', 'Position',[0 0 1 1]);

else
    
    % Setup and Plot Atlas
    % atlas = load('atlasViewer.mat', '-mat'); % An unmodified atlasViewer.mat file 
    % for the common head volume.

    atlas = load(subjDirs{1}, '-mat');
    T = atlas.headvol.T_2mc; % Translation matrix to individual subject space
    Ti(1:4, 1:4) = inv(T(1:4, 1:4)); % Inverse produces translation to common atlas space

    % Head Surface
    fN = trisurfnorm(v, f); % This function is provided in a separate file

    % Pial Surface

    set(hFigHeadDisp(1), 'name','Digitized Probe Positions');
    figure(hFigHeadDisp(1));

    % Original Circle for Patches
    temp = 1:1:21;
    radius = 2.5;
    x = radius * cos(2 * pi * temp(:) / size(temp, 2));
    y = radius * sin(2 * pi * temp(:) / size(temp, 2));
    z(1:size(temp, 2)) = 0;
    circle1 = [x(:), y(:), z(:)];
    circ1N = [0 0 1]; % Normal to the plane of circle 1
    circle2 = circle1; % Create a second circle variable to be modified each loop of s (below)

    % Define the colors to be used for the optodes
    colors1 = colormap;
    for i = 1:1:nSubj
        patchColor(i,:) = colors1(1+round(63*i/nSubj),:);
    end

    % Translate each subject's optode positions onto a common atlas and plot
    rotEig(1:3,1:3,1:nSubj) = 0;
    optN = 100; % Temporary value in case the following loop doesn't run
    nSources = 0;
    for s = 1:1:nSubj
        % Load Subject Data, Transform Probe, Plot Circles Normal to Surface
        sub = load(subjDirs{s}, '-mat');
        nSources = sub.probe.nsrc;
        p = sub.probe.optpos_reg; % Original registered optode positions
        p(:, 4) = 1;
        T = sub.headvol.T_2mc; % Translation matrix to individual subject space
        Ti(1:4, 1:4) = inv(T(1:4, 1:4)); % Inverse produces translation to common atlas space

        % Search for optodes that are closer together than the ssThresh and exclude them
        useList(1:size(p, 1)) = 1;
        for i = 1:1:size(p, 1)
            for j = 1:1:size(p, 1)
                if (sqrt((p(i, 1) - p(j, 1))^2 + (p(i, 2) - p(j, 2))^2 ...
                    + (p(i, 3) - p(j, 3))^2) < ssThresh)
                    % The following statements assume sources are listed 
                    % before detectors and therefore the optode to exclude 
                    % has the higher number
                    if (i > j)
                        useList(i) = 0;
                    end
                    if (j > i)
                        useList(j) = 0;
                    end
                end
            end
            
            % Store orignal positions of ALL optodes
            p2all_orig(i,1:3,s) = xform_apply(p(i,1:3), Ti); 
        end
        
        optN = sum(useList(:));
        p2(1:optN,1:4) = 0;
        j = 1;
        for i=1:1:size(p, 1)
            if (useList(i) ~= 0) % Only entries in the useList are carried to subsequent steps
                p2(j, 1:4) = transpose(Ti * transpose(p(i, 1:4))); % New optode positions in common space
                j = j + 1;
            end
        end

        p2n(1:optN, 1:3) = 0; % Create an array to store the normal vector from the common atlas surface at each optode position
        for i=1:1:optN
            vmin = 1e99; vidx = 0;
            for j = 1:1:size(v, 1)
                foo = sqrt((p2(i,1)-v(j,1))^2 + (p2(i,2)-v(j,2))^2 + (p2(i,3)-v(j,3))^2); % distance from optode to vertex
                if (foo < vmin) % Search for vertex with the minimum distance from the optode
                    vmin = foo;
                    vidx = j;
                end
            end
            [lst, foo] = find(f==vidx); % Using the nearest vertex, find the matching faces
            for j = 1:1:size(lst, 1)
                p2n(i, :) = p2n(i, :) + fN(lst(j), :); % Sum the normal vectors for all matching faces
            end
            p2n(i, :) = p2n(i, :) / size(lst, 1); % Divide by the number of faces to find the average normal vector
            p2T = vrrotvec2mat_copy(vrrotvec_copy(circ1N, p2n(i, :))); % Create a rotation matrix using the original circle normal and the average normal vector for the optode location
            for j = 1:1:size(circle1, 1)
                circle2(j, :) = transpose(p2T * transpose(circle1(j, :))) + p2(i, 1:3); % Rotate and translate the original circle shape into the optode plane and position
            end
            patch(circle2(:, axes_order(1)), circle2(:, axes_order(2)), circle2(:, axes_order(3)), patchColor(s,:)); % Creates a patch using the optode circle on the head volume
        end

        [foo, bar] = eig(sub.headvol.T_2mc(1:3,1:3)); % Calculate the eigenvalues of the rotation matrix from subject space to common atlas space
        rotEig(1:3,1:3,s) = abs(bar); % Store the absolute value of the rotation matrix eigenvalues
        p2all(:,1:4,s) = p2; % Store the subject's translated optode locations for group plot
    end

    % Group-Level Analysis
    scale(1) = mean(rotEig(1,1,:)); % Find the average scaling factor in the X-direction
    scale(2) = mean(rotEig(2,2,:)); % Find the average scaling factor in the Y-direction
    scale(3) = mean(rotEig(3,3,:)); % Find the average scaling factor in the Z-direction

    p2mean(1:optN,1:3) = 0;
    p2error(1:optN,1:nSubj) = 0;
    p2sd(1:optN) = 0;
    for i = 1:1:optN
        for j = 1:1:3
            p2mean(i,j) = mean(p2all(i,j,:)); % Calculate the mean optode locations across subjects
        end
        for j = 1:1:nSubj
            p2error(i,j) = sqrt((((p2all(i,1,j)-p2mean(i,1))) / scale(1))^2 + ...
                (((p2all(i,2,j)-p2mean(i,2))) / scale(2))^2 + ...
                (((p2all(i,3,j)-p2mean(i,3))) / scale(3))^2); % Calculate the Euclidean position error and correct for scaling
        end
        for j = 1:1:nSubj
            p2sd(i) = p2sd(i) + p2error(i,j)^2; % Accumulate Variance
        end
        p2sd(i) = sqrt(p2sd(i) / nSubj); % Standard Deviation, scaled to millimeters
    end
    
    filename = fopen('probes_mean.txt', 'wt');
    for i = 1:1:nSources
        fprintf(filename, '%s%s%s %s %s %s\n', 's', num2str(i), ':', num2str(p2mean(i, 1)), num2str(p2mean(i, 2)), num2str(p2mean(i, 3)));
    end
    for i = 1:1:(optN - nSources)
        fprintf(filename, '%s%s%s %s %s %s\n', 'd', num2str(i), ':', num2str(p2mean(i + nSources, 1)), num2str(p2mean(i + nSources, 2)), num2str(p2mean(i + nSources, 3)));
    end
    fprintf(filename, '\nNz: 131.0 188.0 234.0\n');
    fprintf(filename, 'Iz: 130.0 167.0 26.0\n');
    fprintf(filename, 'Ar: 40.0 201.0 124.0\n');
    fprintf(filename, 'Al: 218.0 203.0 124.0\n');
    fprintf(filename, 'Cz: 130.0 47.9 138.0\n');
    fclose(filename);

    % Plot a second head and pial surface for group-level results
    set(hFigHeadDisp(2), 'name','Standard Deviation Across Digitized Probes (mm)');
    figure(hFigHeadDisp(2));

    % Create a color bar that displays the standard deviation value associated with each color
    setColorBar(p2sd);

    % Plot patches at mean of each probe location
    colors = colormap; % Create a matrix using the current color map for pulling color associated with each value
    p2n(1:optN, 1:3) = 0;
    for i=1:1:optN
        % Find the nearest vertex to each group-mean optode position
        vmin = 1e99; vidx = 0;
        for j = 1:1:size(v, 1)
            foo = sqrt((p2mean(i,1)-v(j,1))^2 + (p2mean(i,2)-v(j,2))^2 + (p2mean(i,3)-v(j,3))^2);
            if (foo < vmin)
                vmin = foo;
                vidx = j;
            end
        end
        [lst, foo] = find(f==vidx);
        
        % Fine the normal vector for each group-mean optode position
        for j = 1:1:size(lst, 1)
            p2n(i, :) = p2n(i, :) + fN(lst(j), :);
        end
        p2n(i, :) = p2n(i, :) / size(lst, 1);

        p2T = vrrotvec2mat_copy(vrrotvec_copy(circ1N, p2n(i, :)));
        for j = 1:1:size(circle1, 1)
            circle2(j, :) = transpose(p2T * transpose(circle1(j, :))) + p2(i, 1:3);
        end
        
        color = 1+round(63*(p2sd(i)-min(p2sd))/(max(p2sd)-min(p2sd))); % This picks the most appropriate of the 64 colormap colors
        patch(circle2(:, axes_order(1)), circle2(:, axes_order(2)), circle2(:, axes_order(3)), ...
            [colors(color, 1) colors(color, 2) colors(color, 3)]); % Creates a patch using the colormap color and group-mean optode circle
    end
    
    % Create UI Table with Mean Probe Information
    hFigTbl = figure('name', 'Mean Optode Positions', 'units','normalized','position', tblFigPos);
    hold on
    tableData = p2mean;
    tableData(:, 4) = transpose(p2sd);
    hTbl = uitable(hFigTbl, 'Data', tableData, 'ColumnName', {'X', 'Y', 'Z', 'Standard Deviation (mm)'}, ...
        'units','normalized', 'Position',[0,0,.9,1]);

    
    if size(sub.probe.srcpos,1) == size(atlasViewer.probe.srcpos,1)
        if size(sub.probe.detpos,1) == size(atlasViewer.probe.detpos,1)
            
            p2all_orig_gmean = [mean(p2all_orig(:,1,:),3), mean(p2all_orig(:,2,:),3), mean(p2all_orig(:,3,:),3)];
            atlasViewer.probe.optpos_reg_mean = p2all_orig_gmean;
            atlasViewer.probe = findMeasMidPts(atlasViewer.probe,'group');            

        end
    end
    
end

cd(wd)



% ----------------------------------------------------------------
function selectTable(hObject, eventdata)
global atlasViewer
global tableData
global hTbl

T_labelssurf2vol = atlasViewer.labelssurf.T_2vol;
T_headvol2mc     = atlasViewer.headvol.T_2mc;
T_mc2mni = inv(T_headvol2mc*T_labelssurf2vol);

tbl = tableData;
if get(hObject, 'value')==1
    for ii=1:size(tableData,1)
        tbl(ii,1:3) = xform_apply(tableData(ii,1:3), T_mc2mni);
        if size(tableData,2)>4
            tbl(ii,4:6) = xform_apply(tableData(ii,4:6), T_mc2mni);
        end
    end
elseif get(hObject, 'value')==0
    tbl = tableData;
end
set(hTbl, 'data', tbl);



% -------------------------------------------------------------------------
function lights = setLighting(obj, hAxes)

axes(hAxes);

if isstruct(obj)
    if obj.isempty(obj)
        return;
    end
    v = obj.mesh.vertices;
else
    v = obj;
end

%%% Position; set up light in all 8 corners so that no part 
%%% of the head is in the dark
b = gen_bbox(v, 20);

% Find the midpoints between the corners of the bounding box
% Lights will be added at those midpoints. 
m(1,:)  = (b(1,:)+b(4,:))/2;
m(2,:)  = (b(1,:)+b(6,:))/2;
m(3,:)  = (b(1,:)+b(7,:))/2;
m(4,:)  = (b(2,:)+b(8,:))/2;
m(5,:)  = (b(3,:)+b(8,:))/2;
m(6,:)  = (b(5,:)+b(8,:))/2;

% p = [b; m];
p = b;

lights = [ones(size(p,1),1)];

c = ones(size(p,1),3)*.6;

%%% Lights on/off, local/infinite
%%% Create the cameras
for ii=1:size(p, 1)
    if lights(ii)==1
        visible='on';
    elseif lights(ii)==0
        visible='off';
    end
    hl(ii,1) = camlight;
    set(hl(ii,1),'position', p(ii,:),'color',[c(ii,1) c(ii,2) c(ii,3)],...
        'visible',visible,'style','local');
    
end
lighting phong




% -------------------------------------------------------------------------
function hFigHeadDisp = getHeadFigures(v, f, vp, fp, axes_order)

c = v(:,3); % Creating a vector of equal length to v, to be used as color values
c(:) = 100; % 100, using clim [100, 200], produces a blue color

% Pial Surface
cp = vp(:,3); % Creating a vector of equal length to vp, to be used as color values
cp(:) = 150; % 150, using clim [100, 200], produces a green color

hFigHeadDisp = [];
surfcolor = [.82,.80,.78,];
p = [];
for ii=1:2
    hFigHeadDisp(ii) = figure('unit','normalized');
    if isempty(p)
        p = get(hFigHeadDisp(ii),'position');
        set(hFigHeadDisp(ii), 'position',[p(1)-.15, p(2), p(3), p(4)]);
    else
        set(hFigHeadDisp(ii), 'position',[p(1)+.15, p(2), p(3), p(4)]);
    end
    clf
    hold on
    set(gca,'clim',[100 200])
    h = trisurf(f, v(:,axes_order(1)), v(:,axes_order(2)), v(:,axes_order(3)), c(:)); % Plot head surface
    set(h, 'linestyle', 'none', 'facealpha', 0.45, 'facecolor',surfcolor) % Remove lines and set opacity to 25%
    set(h,'diffusestrength',.9,'specularstrength',.12,'ambientstrength',.2);
    h2 = trisurf(fp, vp(:,axes_order(1)), vp(:,axes_order(2)), vp(:,axes_order(3)), cp(:)); % Plot pial surface
    set(h2, 'linestyle', 'none', 'facealpha', 1, 'facecolor',surfcolor-.20) % Remove lines and set opacity to 100%
    set(h2,'diffusestrength',.9,'specularstrength',.12,'ambientstrength',.2);
    lights = setLighting(v, gca);
    axis('off')
    axis image
    view(-90, 0)
end



% -------------------------------------------------------
function [subjDirs, errstr] = findSubjDirs()

subjDirs = {};

kk=1;
errstr = '';
files = dir;
for ii=1:length(files)
    if ~files(ii).isdir
        continue;
    end
    if strcmp(files(ii).name, '.')
        continue;
    end
    if strcmp(files(ii).name, '..')
        continue;
    end
    if exist([files(ii).name, '/atlasViewer.mat'], 'file')==2
        load([files(ii).name, '/atlasViewer.mat']);
        if isempty(probe.optpos_reg)
            if ~isempty(probe.optpos)
                if isempty(errstr)
                    errstr = sprintf('%s/\n', files(ii).name);
                else
                    errstr = sprintf('%s%s/\n', errstr, files(ii).name);
                end
            end
            continue;
        end
        subjDirs{kk} = [files(ii).name, '/atlasViewer.mat'];
        kk=kk+1;
    end
end




% ----------------------------------------------------------------
function r = errCheck(subjDirs, errmsg)

r = 0;
if length(subjDirs)<2
    msg{1} = sprintf('Warning: need at least 2 subjects with atlasViewer.mat and\n');
    msg{2} = sprintf('registered probe to calculate probe placement variation.\n');    
    MenuBox(msg, 'OK');
    if ~isempty(errmsg)
        msg2{1} = sprintf('The following subject folders have probes that are NOT registered\n');
        msg2{2} = sprintf('to the head surface :\n\n');
        msg2{3} = sprintf('%s\n', errmsg);
        msg2{4} = sprintf('Check that all subject probes have been registered to the head\n');
        msg2{5} = sprintf('surface.\n');
        MenuBox(msg2, 'OK');
    end
    r = -1;
end


% --------------------------------------------------------------------------
function setColorBar(p2val)

colorbar('yticklabel', {0.10 * round(0*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(1*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(2*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(3*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(4*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(5*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(6*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(7*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(8*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(9*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val)), ...
                        0.10 * round(10*((max(p2val)-min(p2val))))+0.10*round(10*min(p2val))});


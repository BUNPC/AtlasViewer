function drawdtfconngraph(dtfVal, roiPos, inopt)
% drawdtfconngraph - draw arrow connectivity patterns among multiple channels.
%
% Usage: drawdtfconngraph(dtfVal, roiPos, inopt)
%
% Input: dtfVal - the DTF values at a frequency component, where dtfVal(i,j)
%                       means the information flow from channel j to channel i.
%           roiPos - a 2D array (N * 3) for the locations of the channels.
%           inopt - a structure stores options for drawing the arrow patterns.
%                      It has 5 fields:
%                      inopt.Channels - number of arrow patterns to display.
%                                                 including 'all', 'single' and 'none'.
%                      inopt.Whichchannel - two channels ( [i, j] ) connected by the arrow.
%                                                         It is valid for 'single' arrow only (from j to i).
%                      inopt.ValLim - limits for displaying the arrow patterns.
%                                             Only the arrow patterns relative to the DTF values in
%                                             [min, max] scope will be displayed.
%                      inopt.ArSzLt - the limits of the arrow size.
%                      inopt.SpSzLt - the limits of the sphere size.
%                                              It is not valid for drawing arrow patterns.
%
% Program Authors: Laura Astolfi and Fabio Babiloni, University of Rome "La Sapienza"
%
% Reference (please cite):
%         Babiloni F, Cincotti F, Babiloni C, Carducci F, Mattia D, Astolfi L, Basilisco A, Rossini PM,
%         Ding L, Ni Y, Cheng J, Christine K, Sweeney J, He B. Neuroimage. 2005 Jan 1;24(1):118-31.
%         Estimation of the cortical functional connectivity with the multimodal integration of high-resolution
%         EEG and fMRI data by directed transfer function.
%

% License
% ==========================================
% This program is part of the eConnectome.
%
% Copyright (c) 2010 Fabio Babiloni and Laura Astolfi
%
% This program is free software for academic research: you can redistribute it and/or modify
% it for non-commercial uses, under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program. If not, see http://www.gnu.org/copyleft/gpl.html.
%
% This program is for research purposes only. This program
% CAN NOT be used for commercial purposes. This program 
% SHOULD NOT be used for medical purposes. The authors 
% WILL NOT be responsible for using the program in medical
% conditions.
% ==========================================

% Revision Logs
% ==========================================
%
% Yakang Dai, University of Minnesota, 01-Mar-2010 15:20:30
% Release Version 1.0 beta
%
% ==========================================


nRois = size(dtfVal, 1);

ArrowSizeLimit = inopt.ArSzLt;

arcH = -ones(nRois, nRois);
arwH = -ones(nRois, nRois);

dispmin = inopt.ValLim(1);
dispmax = inopt.ValLim(2);

mat = dtfVal;
% mat(~mat)=nan;
valmin = min(min(mat));
valmax = max(max(mat));

cmap = colormap; 
cnum = size(cmap,1);
maxmin = valmax-valmin;
if ~maxmin
    maxmin = 1.0;
end

hold on;

if isequal(inopt.Channels,'none')
    return;
elseif isequal(inopt.Channels,'single')        
    rr = inopt.Whichchannel(1);
    cc = inopt.Whichchannel(2);
    if dtfVal(rr, cc) < dispmin -1e-6 |  dtfVal(rr, cc) > dispmax + 1e-6 % do not display connectivity values outside the limit.
        return;
    end
    
    if dtfVal(rr, cc) <= 0.0 % do not display zero connectivity values.
        return;
    end
    
    normVal=(dtfVal(rr, cc) - valmin)/maxmin;
    normVal = min(max(0, normVal), 1);
    siz = ArrowSizeLimit(1) + diff(ArrowSizeLimit) * normVal;
        
    colidx = round(normVal*(cnum-1)+1);
    col = cmap(colidx,:)*0.9;

    [arcH(rr, cc) arwH(rr, cc)]=drawpipe(roiPos(cc, :), roiPos(rr, :), siz); % from output 'cc' to input 'rr' 
    set([arcH(rr, cc); arwH(rr, cc)], 'faceColor', col);
else %'all'
    for rr=[1:nRois]
        for cc=[1:nRois]
            if dtfVal(rr, cc) < dispmin -1e-6 |  dtfVal(rr, cc) > dispmax + 1e-6 % do not display connectivity values outside the limit.
                continue;
            end
            
            if dtfVal(rr, cc) <= 0.0 % do not display zero connectivity values.
                continue;
            end
            
            normVal=(dtfVal(rr, cc) - valmin)/maxmin;
            normVal = min(max(0, normVal), 1);
            siz = ArrowSizeLimit(1) + diff(ArrowSizeLimit) * normVal;
        
            colidx = round(normVal*(cnum-1)+1);
            col = cmap(colidx,:);

            [arcH(rr, cc) arwH(rr, cc)]=drawpipe(roiPos(cc, :), roiPos(rr, :), siz); % from output 'cc' to input 'rr' 
            set([arcH(rr, cc); arwH(rr, cc)], 'faceColor', col);
        end% for cc
    end% for rr    
end

function [pipeH, arrowH]=drawpipe(A, B, radius, opt)
X_=1; Y_=2; Z_=3;
if nargin < 4
opt=struct( ...
   'Radius', 2, ...
   'Color', 'b', ...
   'PrismSides', 16, ...
   'DrawMode', 'WHOLE', ... % 'WHOLE' 'HALF' 'DISPLACED'...
   'AspectRatio', .5, ...
   'ArrowType', 'END', ...% 'NONE' 'END'
   ...
   'ArchType', 'HALFCIRCLE', ... % 'TEST' 'STREIGHT' 'HALFCIRCLE' 'ARCH' 
   'PipeSegments', 20 ...
   );
end% if
if nargin>2 & ~isempty(radius)
   opt.Radius=radius;
end% if
switch opt.ArchType
   case 'TEST'
      edges=[
         -50 -50 0
         -20 20 0
         50 50 0
      ];
   case 'STREIGHT'
      edges=[A; B];
   case 'HALFCIRCLE'
      edges=zeros([opt.PipeSegments 3]);
      segmLen=norm(B-A);
      t_dir=(B-A)./segmLen;
%      z_dir=[0 0 1];
      z_dir = (A+B)/2;
      z_dir = z_dir/norm(z_dir);
      z_dir = z_dir + [0 0 2];
      z_dir = z_dir/norm(z_dir);
      phi=linspace(pi/2, 0, opt.PipeSegments)';
      rho=segmLen.*cos(phi);
      edges(:, X_) = A(X_) + rho .*(z_dir(X_).*sin(phi) + t_dir(X_).*cos(phi));
      edges(:, Y_) = A(Y_) + rho .*(z_dir(Y_).*sin(phi) + t_dir(Y_).*cos(phi));
      edges(:, Z_) = A(Z_) + rho .*(z_dir(Z_).*sin(phi) + t_dir(Z_).*cos(phi));
   case 'ARCH'
end% switch

% radius=[];
[pipes arrow]=pipe(edges, radius, opt);

%---

wasHold=ishold;
pipeH=surf(pipes.X, pipes.Y, pipes.Z, 'EdgeColor', 'none', 'FaceColor', 'b','FaceLighting', 'phong','Tag','Arrow');
% material default; 
% lighting phong;
hold on
arrowH=surf(arrow.X, arrow.Y, arrow.Z, 'EdgeColor', 'none', 'FaceColor', 'b','FaceLighting', 'phong','Tag','Arrow');
% material default; 
% lighting phong
if ~wasHold
   hold off
end% if

function [pipe, arrow]=pipe(edges, radius, opt)
% TODO: non usare l'asse zeta, ma la direzione centripeta per definire le
% normali.
ARROWLEN=2.2;
ARROWRADIUS=2;
if nargin < 3
   opt=struct( ...
      'Radius', 10, ...
      'PrismSides', 8, ...
      'DrawMode', 'WHOLE', ... % 'WHOLE' 'HALF' 'DISPLACED'...
      'AspectRatio', .5, ...
      'ArrowType', 'MIDDLE' ...% 'NONE' 'END'
      );
end% if
if nargin>1 & ~isempty(radius)
   opt.Radius=radius;
end% if
% TODO: inizializzare pipe.X,Y,Z
nEdges=size(edges, 1);
arrowE=ceil(nEdges/2);
for ee=[1:nEdges-1]
   startPos=edges(ee, :);
   endPos=edges(ee+1, :);
   
   temp=[endPos-startPos];
   t_dir=temp./norm(temp);
   %
   if ee==1
      [pipe.X(1, :) pipe.Y(1, :) pipe.Z(1, :)] = basecontour(startPos, t_dir, opt);
   else
      temp=.5*(lastTDir+t_dir);
      startTdir=temp./norm(temp);
      [pipe.X(ee, :) pipe.Y(ee, :) pipe.Z(ee, :)] = basecontour(startPos, startTdir, opt);
   end% if 0
   %
   if strcmp(opt.ArrowType, 'MIDDLE') & ee==arrowE
      midPoint=.5*(startPos+endPos);
      startpoint=midPoint-.5*ARROWLEN*opt.Radius.*t_dir;
      arrow=arrowcontour(startpoint, ARROWLEN*t_dir, opt, ARROWRADIUS);
   end% if
   %
   lastTDir=t_dir;
end% for ee
if strcmp(opt.ArrowType, 'END')
   endPoint=endPos-ARROWLEN*t_dir;
   [pipe.X(nEdges, :) pipe.Y(nEdges, :) pipe.Z(nEdges, :)] = basecontour(endPoint, lastTDir, opt);
   arrow=arrowcontour(endPoint, ARROWLEN*t_dir, opt, ARROWRADIUS);
else
   [pipe.X(nEdges, :) pipe.Y(nEdges, :) pipe.Z(nEdges, :)] = basecontour(endPos, lastTDir, opt);
end% if
%

%==========================================================================
function arrow=arrowcontour(baseCenter, axis, opt, radiusFactor);

arrowLen=norm(axis);
t_dir=axis./arrowLen;

aStartPos=baseCenter;
aOpt1=opt;
aOpt1.Radius=0*opt.Radius;
[arrow.X(1, :) arrow.Y(1, :) arrow.Z(1, :)] = basecontour(aStartPos, t_dir, aOpt1);
aOpt2=aOpt1;
aOpt2.Radius=radiusFactor*opt.Radius;
[arrow.X(2, :) arrow.Y(2, :) arrow.Z(2, :)] = basecontour(aStartPos, t_dir, aOpt2);
aEndPos=baseCenter+arrowLen*opt.Radius.*t_dir;
aOpt3=opt;
aOpt3.Radius=0*opt.Radius;
[arrow.X(3, :) arrow.Y(3, :) arrow.Z(3, :)] = basecontour(aEndPos, t_dir, aOpt3);
if 1% utile se si usa il lighting phong
   arrow1=arrow;
   arrow.X=arrow1.X([1 2 2 3], :);
   arrow.Y=arrow1.Y([1 2 2 3], :);
   arrow.Z=arrow1.Z([1 2 2 3], :);
end% if


%--------------------------------------------------------------------------
function [X, Y, Z]=basecontour(center, t_dir, opt)
X_=1; Y_=2; Z_=3;
% z_dir=[0 0 1];
z_dir = center/norm(center);
z_dir = z_dir + [0 0 2];
z_dir = z_dir/norm(z_dir);

if t_dir(3)>1-eps
   n_xy=[1 0 0];
   n_z=[0 1 0];
else   
   temp=cross(t_dir, z_dir);
   n_xy=temp./norm(temp);
   n_z=cross(n_xy, t_dir);
end% if

switch opt.DrawMode
   case 'WHOLE'
      phi=linspace(-pi, pi, opt.PrismSides);
      rho=opt.Radius.*ones(size(phi));
   case 'HALF'
      phi=linspace(-pi/2, pi/2, opt.PrismSides);
      rho=opt.Radius.*ones(size(phi));
   case 'DISPLACED'
      phi=linspace(-pi/2, pi/2, opt.PrismSides);
      rho=opt.Radius.*cos(phi);
end% swich
% l_vec = ( n_xy.*sin(phi) + n_z.*cos(phi) );
X=center(X_) + rho .* ( n_xy(X_).*cos(phi) + opt.AspectRatio.*(n_z(X_).*sin(phi)) );
Y=center(Y_) + rho .* ( n_xy(Y_).*cos(phi) + opt.AspectRatio.*(n_z(Y_).*sin(phi)) );
Z=center(Z_) + rho .* ( n_xy(Z_).*cos(phi) + opt.AspectRatio.*(n_z(Z_).*sin(phi)) );


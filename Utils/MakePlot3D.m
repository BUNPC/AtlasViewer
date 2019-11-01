function [h hAxes] = MakePlot3D ( MAT, MS, ColorMap, Flp, BgColor, NewFig )

% MAKEPLOT3D - Generate nice plot of vectorized head or brain.
%
% USEAGE.
%   h = MakePlot3D ( MAT, MS, ColorMap, Flp, BgColor );
%
% DESCRIPTION.
%   This function will paint [n,3] matrix of Cartesian coordinates. Points
%   in MAT matrix create head or brain surface. Points are colored
%   according distance from computed center of the matrix.
%
% INPUTS.
%   MAT is [n,3] matrix of vectorized discrete points. Created by
%   IMAGEREAD3D.
%   MS - MarkerSize - is size of plotted MAT points. Default is 10.
%   ColorMap - is string indicating supported Matlab Colormaps.
%              Some possible color strings are:
%
%                'colorcube'
%                'copper'
%                'gray'
%                'hsv'
%                'lines'
%                'prism'
%                'summer'
%                'winter'
%                'pink'
%
%   Default is 'bone'.
%   Flp - string 'FlipCM' will flip ColorMap matrix.
%   e.g.  MakePlot3D ( [n,3], 7, 'hsv', 'FlipCM' );
%
% OUTPUT.
%   Colored plot.
%
% EXAMPLE.
%   open ('MakePlot3D_plot.fig')
%
% See also IMAGEREAD3D

%   Brain Research Group
%   Food Physics Laboratory, Division of Food Function,
%   National Food Research Institute,  Tsukuba,  Japan
%   WEB: http://brain.job.affrc.go.jp,  EMAIL: valo@nfri.affrc.go.jp
%   AUTHOR: Valer Jurcak,   DATE: 9.jun.2005,    VERSION: 1.0
%
%   * Updated Dec 17, 2008 by Jay Dubb
%     a) Added argument BgColor to set the color of the background
%     b) Added comments in the help section for possible color scheme strings
%     c) Add output variable h, to return the handle of the figure in which
%        the display object appears.
%-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-



% Checking inputs ........................................................
if nargin == 1 % marix is too small
    ss = size(MAT);
    if ss(1) < 4 | ss(2) ~= 3;
        error('Input MAT must be [N,3] matrix, min N is 4');
    end
end


% Only 1 input
if nargin == 1
    MS = 10; % default marker size
    ColorMap = 'bone'; % default colormap
    Flp = 'FlipCM'; % flip colormap
    Name = 'SeePlot'; % default name
end


% Only 2 inputs
if nargin == 2
    
    % second input is marker size MS ........................
    if sum(size(MS))== 2
        ColorMap = 'bone';
        Flp = 'FlipCM';
    end
    
    % second input is color map matrix ColorMap ..............
    if isequal(MS, 'autumn') | isequal(MS, 'bone') |...
       isequal(MS, 'colorcube') | isequal(MS, 'cool') |...
       isequal(MS, 'copper')  | isequal(MS, 'flag') |...
       isequal(MS, 'gray')  | isequal(MS, 'hot') |...
       isequal(MS, 'hsv')  | isequal(MS, 'jet') |...
       isequal(MS, 'lines')  | isequal(MS, 'pink') |...
       isequal(MS, 'prism')  | isequal(MS, 'spring') |...
       isequal(MS, 'summer')  | isequal(MS, 'white') |...
       isequal(MS, 'winter')
        
        ColorMap = MS; % revers variables
        MS = 10;
    end
    
    % second input is flip color map FlipCM ...................
    if isequal(MS, 'FlipCM')
        Flp = MS; % revers variables
        MS = 10;
        ColorMap = 'bone';
    end
end



% Only 3 inputs
if nargin == 3
    
    % MS is missing ...................
    if isequal(MS, 'autumn') | isequal(MS, 'bone') |...
       isequal(MS, 'colorcube') | isequal(MS, 'cool') |...
       isequal(MS, 'copper')  | isequal(MS, 'flag') |...
       isequal(MS, 'gray')  | isequal(MS, 'hot') |...
       isequal(MS, 'hsv')  | isequal(MS, 'jet') |...
       isequal(MS, 'lines')  | isequal(MS, 'pink') |...
       isequal(MS, 'prism')  | isequal(MS, 'spring') |...
       isequal(MS, 'summer')  | isequal(MS, 'white') |...
       isequal(MS, 'winter') ...
       & ...
       isequal(ColorMap, 'FlipCM')
        
        ColorMap = MS;
        Flp = ColorMap;
        MS = 10;
    end
    
    
    % third input is flipping info  .................
    if isequal(ColorMap, 'FlipCM')
        ColorMap = 'bone';
        Flp = 'FlipCM';
    end
end




% ALGORITHM ..............................................................

% Here we'll check matrix MAT, we delete NaN rows if exist ...............
% It can happen after normalization
[i,j] = find(isnan(MAT));
MAT(i,:) = [];
clear i j


% Here we'll find centre of head or brain ................................
Centricius = mean(MAT);

% Compute distance from Centricius to each surface point .................
R = DistanceBetween( Centricius, MAT ); % call function
R = round(R); % don't need exact distance for painting


% We'll find min & max value of R ........................................
minR = min(R);
maxR = max(R);


% Define rank of painting ................................................
L = maxR/2; % nice predefined rank, change it if you want
M = maxR*1.2;


% Range of rank ..........................................................
DistRank = L : M;
DistRank = round(DistRank); % round values


% We get length DistRank .................................................
dr = length(DistRank);


% Define ColorBox ........................................................
magic_str = [ 'ColorBox = ' ColorMap,'(dr);'];
eval(magic_str);
clear magic_str


% Maybe is nicer to flip colormap ........................................
if ~exist('Flp','var'), Flp = 'DontFlip'; end % don't want to flip

if isequal(Flp, 'FlipCM') % yes we want to flip colormap
    ColorBox = flipud(ColorBox); % flipud colormap
end


% Plot style .............................................................
if(exist('BgColor'))
    colordef(BgColor);
else
    colordef('black');
end

if exist('NewFig','var') && NewFig==1
    figure;
    hold on
    grid on
    view(3)
    xlabel('X'), ylabel('Y'), zlabel('Z')
    hAxes = gca;
else
    hold on
    hAxes = gca;
end

% Painting points according distance from Centricius .....................
if ~exist('MS', 'var'), MS = 10; end % MS was not defined

h = cell(1,dr);
for n = 1 : dr
    Sel = ( R == DistRank(n)); % select points with same distance
    h{n} = plot3(MAT(Sel,1), MAT(Sel,2), MAT(Sel,3),...
                 '.', 'Color', ColorBox(n,:), 'MarkerSize', MS);
    clear Sel
end

h = [h{:}];

% hold off
% rotate3d on

% Saving plot ............................................................
% saveas( gcf, 'abc.fig')





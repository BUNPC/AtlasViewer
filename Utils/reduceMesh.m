function varargout = reduceMesh(varargin)

if nargin==1
    mesh   = varargin{1};
    option = 'fast';
elseif nargin==2
    if isstruct(varargin{1})
        mesh   = varargin{1};
        R      = varargin{2};
        option = 'fast';
    else
        mesh.vertices = varargin{1};
        mesh.faces    = varargin{2};
        option        = 'slow';
    end
elseif nargin==3
    mesh.vertices = varargin{1};
    mesh.faces    = varargin{2};
    R             = varargin{3};
    option        = 'slow';
else
    if isstruct(varargin{1})
        varargout{1} = mesh;
    else
        varargout{1} = mesh.vertices;
        varargout{2} = mesh.faces;
    end
end

if ~exist('R','var') | isempty(R)
    if size(mesh.faces,1)>40000
        R = 40000/size(mesh.faces,1);
    else
        if isstruct(varargin{1})
            varargout{1} = mesh;
        else
            varargout{1} = mesh.vertices;
            varargout{2} = mesh.faces;
        end
    return;
end
end

if ~exist('option','var') | isempty(option)
    option = 'fast';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check if number of elements is too large. If greater than 40,000 then
% need to reduce
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(option, 'fast')
    mesh = reducepatch(mesh, R);
else
    try
        [mesh.vertices, mesh.faces] = meshresample(mesh.vertices, mesh.faces, R);
    catch
        msg = sprintf('ERROR Downsampling mesh. Will try another function...\n');
        fprintf(msg);
        mesh = reducepatch(mesh, R);
    end
end


if isstruct(varargin{1})
    varargout{1} = mesh;
else
    varargout{1} = mesh.vertices;    
    varargout{2} = mesh.faces;
end

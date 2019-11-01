function b = existsHeadsurf(varargin)

if nargin==0 || isempty(varargin{1})
    global atlasViewer
    headsurf = atlasViewer.headsurf;
else
    headsurf = varargin{1};
end

b = ishandles(headsurf.handles.surf);


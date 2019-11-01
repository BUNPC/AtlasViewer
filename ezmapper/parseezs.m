function theStruct = parseEZS(filename)
% PARSEEZS Convert EZS file to a MATLAB structure.
% based on parseXML from MATLAB help doc for xmlread
%
% K. Perdue
% September 3, 2010
%
% EZS=parseEZS('20100901_003.ezs');
%
try
   tree = xmlread(filename);
catch
   error('Failed to read EZS file %s.',filename);
end

% Recurse over child nodes. This could run into problems 
% with very deeply nested trees.
try
   Struct1 = parseChildNodes(tree);
catch
   error('Unable to parse EZS file %s.',filename);
end

% convert numeric fields to matrices or arrays
try
    theStruct=struct(Struct1.Attributes(1).Name, str2num(Struct1.Attributes(1).Value));
    for ii=2:length(Struct1.Attributes)
        if (regexp(Struct1.Attributes(ii).Value,'[a-zA-Z:\/_]')) % specific to Q. Fang EZS file
            theStruct=setfield(theStruct, Struct1.Attributes(ii).Name, Struct1.Attributes(ii).Value);
        else
            theStruct=setfield(theStruct, Struct1.Attributes(ii).Name, str2num(Struct1.Attributes(ii).Value));
        end
    end
catch
    error('Unable to fix EZS file when parsing %s.',filename);
end


% ----- Subfunction PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
children = [];
if theNode.hasChildNodes
   childNodes = theNode.getChildNodes;
   numChildNodes = childNodes.getLength;
   allocCell = cell(1, numChildNodes);

   children = struct(             ...
      'Name', allocCell, 'Attributes', allocCell,    ...
      'Data', allocCell, 'Children', allocCell);

    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        children(count) = makeStructFromNode(theChild);
    end
end

% ----- Subfunction MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.

nodeStruct = struct(                        ...
   'Name', char(theNode.getNodeName),       ...
   'Attributes', parseAttributes(theNode),  ...
   'Data', '',                              ...
   'Children', parseChildNodes(theNode));

if any(strcmp(methods(theNode), 'getData'))
   nodeStruct.Data = char(theNode.getData); 
else
   nodeStruct.Data = '';
end

% ----- Subfunction PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.

attributes = [];
if theNode.hasAttributes
   theAttributes = theNode.getAttributes;
   numAttributes = theAttributes.getLength;
   allocCell = cell(1, numAttributes);
   attributes = struct('Name', allocCell, 'Value', ...
                       allocCell);

   for count = 1:numAttributes
      attrib = theAttributes.item(count-1);
      attributes(count).Name = char(attrib.getName);
      attributes(count).Value = char(attrib.getValue);
   end
end
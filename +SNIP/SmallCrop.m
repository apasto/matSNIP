function CropBigArr = SmallCrop(BigLat,BigLon,BigArr,SmallLat,SmallLon)
%SmallCrop Given two maps, 'Big' and 'Small', crop 'Big' to the extent of 'Small'
%   Typical usage: a 'Small' map which used 'Big' map as input,
%   but underwent projection/unprojection and/or removal of edge effects.
%   To perform direct comparison on data, we need to crop 'Big'
%   to the extent of small.
%   'Big' is given as Lat, Lon vectors and a Lat,Lon array,
%   while only the Lat, Lon vectors of 'Small' are needed.
%   Input checks:
%    - are all the Lat, Lon vectors northward, eastward sorted?
%          (i.e. increasing)
%    - is the step between elements constant?
%    - are the steps of 'Big' and 'Small' the same?
%    - do 'Big' and 'Small' share the same origin?
%          (they may have the same step, but the grids may not coincide)
%
% Syntax: CropBigArr = SmallCrop(BigLat,BigLon,BigArr,SmallLat,SmallLon,SmallArr)
%
% Input:
%    BigLat   : 'Big' latitude vector
%    BigLon   : 'Big' longitude vector
%    BigArr   : 'Big' map-array, Lat x Lon
%    SmallLat : 'Small' latitude vector
%    SmallLon : 'Small' longitude vector
%
% Output:
%    CropBigArr : 'Big' map-array, cropped to the extent defined by
%                 SmallLat and SmallLon
%
% 2018, Alberto Pastorutti

%% check input
% transpose lat, long vectors to row, if needed
if iscolumn(BigLat);   BigLat=BigLat';     end
if iscolumn(BigLon);   BigLon=BigLon';     end
if iscolumn(SmallLat); SmallLat=SmallLat'; end
if iscolumn(SmallLon); SmallLat=SmallLon'; end

% inputname(n) is used to print out the offending argument name in errors
% inputname provides an empty output if the argument is not a variable name
% e.g. a function call, or a structure field
% if this happens, use fallback, non-dynamic, argument names ('Robust')
RobustInputNames = {...
    'BigLat (1st arg of SmallCrop)',...
    'BigLon (2nd arg of SmallCrop)',...
    'BigArr (3rd arg of SmallCrop)',... % 'BigArr' is unused, but kept for clarity
    'SmallLat (4th arg of SmallCrop)',...
    'SmallLon (5th arg of SmallCrop)'...
    };
for n=1:nargin
    if ~isempty(inputname(n))
        RobustInputNames{n} = inputname(n);
    end
end

% embedded functions, to avoid writing everyting four times
% using inputname(argNumber) to print out variable names in errors
AssertInputsTogether(BigLat,SmallLat,RobustInputNames{1},RobustInputNames{4});
AssertInputsTogether(BigLat,SmallLat,RobustInputNames{2},RobustInputNames{5});

%% find crop indices
CropEdge_W = find(BigLon==min(SmallLon),1);
CropEdge_E = find(BigLon==max(SmallLon),1);
CropEdge_S = find(BigLat==min(SmallLat),1);
CropEdge_N = find(BigLat==max(SmallLat),1);

if any([isempty(CropEdge_W),...
        isempty(CropEdge_E),...
        isempty(CropEdge_S),...
        isempty(CropEdge_N)])
    warning('No intersection found')
end

%% crop
CropBigArr = BigArr(CropEdge_S:CropEdge_N,CropEdge_W:CropEdge_E);

%% functions: perform input checks
    function AssertInputsTogether(BigIn,SmallIn,BigInVarName,SmallInVarName)
        % this calls AssertInputsEach for single-input-tests
        % and performs Big-Small comparisons
        
        % non-comparison tests: increasing coordinates, constant step
        StepBig   = AssertInputsEach(BigIn,BigInVarName);
        StepSmall = AssertInputsEach(SmallIn,SmallInVarName);
        
        % Big-Small comparison: same step?
        assert(StepBig==StepSmall,['Non equal steps: ',...
            BigInVarName,'=',num2str(StepBig),' and '...
            SmallInVarName,'=',num2str(StepSmall)]);
        
        % Big-Small comparison: same origin?
        % strategy:
        %  1) crop biglat/lon to length of smallat/lon
        %  2) subtract small to big_cropped
        %  3) mod(result of item 2, step)
        %  4) all zeros? same origin
        %  5) otherwise, different origin
        BigCrop = BigIn(1:length(SmallIn));
        assert(all(mod(SmallIn-BigCrop,StepBig)==0),...
            ['Different origin, non coinciding grids defined by: ',...
            BigInVarName,' and ',SmallInVarName]);
    end

    function VectStep = AssertInputsEach(CoordVect,InVarName)
        % called inside AssertInputsTogether
        % instead of writing non-comparison tests twice (for Big and Small)
        DiffCoordVect = diff(CoordVect);
        % 1) are coordinates increasing
        assert(all(DiffCoordVect>0),...
            ['Non increasing coordinate vector: ',InVarName]);
        % 2) are the steps constant?
        assert(all(DiffCoordVect==DiffCoordVect(1)),...
            ['Non constant-step coordinate vector: ',InVarName]);
        % write out step
        VectStep = DiffCoordVect(1);
    end

end


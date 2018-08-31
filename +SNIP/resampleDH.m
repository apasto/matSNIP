function [outArr,outLon,outLat] = resampleDH(inArr,inLon,inLat,outStep,outSampling,method,varargin)
%resampleDH resample grid to a grid complying to Driscoll and Healy (1994)
%           sampling theorem, with a defined step size
%           and the choice between NxN or Nx2N sampling.
%           'inArr' and 'outArr' must be in (Lon, Lat) form
%
% Syntax: [outArr,outLon,outLat] = ...
%             SNIP.resampleDH(inArr,inLon,inLat,...
%                             outStep,outSampling,...
%                             method,[extrapval]
%
% Inputs:
%    inArr       : array, input values, rectangularly sampled
%    inLon       : lon vector
%    inLat       : lat vector
%    outStep     : latitude step in output grid, scalar
%    outSampling : either 'nxn' or 'nx2n', case insensitive
%    method      : interpolation method, passed to 'interp2' (see doc)
%    [extrapval] : 'interp2' value outside domain, default = empty
%
% Outputs:
%    outArr : array, resampled output values
%    outLon : output lon vector
%    outLat : output lat vector
%
% 2018, Alberto Pastorutti

narginchk(6,7)
nargoutchk(3,3)

if nargin==6
    extrapval = [];
else
    extrapval = varargin{1};
end

%% switch outSampling
switch lower(outSampling)
    case 'nxn'
        outLonFactor = 2;
    case 'nx2n'
        outLonFactor = 1;
    otherwise
        error('outSampling must be either ''nxn'' or ''nx2n''.')
end

%% build out grid
% discard westmost meridian, southernmost parallel
LonMin = -180;
LonMax = 180-outLonFactor*outStep;
LatMin = -90+outStep;
LatMax = 90;

outLon = LonMin:outLonFactor*outStep:LonMax;
outLat = LatMin:outStep:LatMax;

[outMeshLon,outMeshLat] = meshgrid(outLon,outLat);

%% build in meshgrid
[inMeshLon,inMeshLat] = meshgrid(inLon,inLat);

%% interpolate
if isempty(extrapval)
    outArr = interp2(inMeshLon,inMeshLat,inArr,outMeshLon,outMeshLat,method);
    outArr(isnan(outArr)) = 0;
else
    outArr = interp2(inMeshLon,inMeshLat,inArr,outMeshLon,outMeshLat,method,extrapval);
end


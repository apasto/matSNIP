function [n,e,ArrUTM,UTMstruct] = FwdRepro(Lat,Lon,Arr,step,varargin)
%FwdRepro Project array (rectangularly sampled) from WGS84 to UTM coordinates.
%         this is done by :
%             0) building a meshgrid for the input array
%             1) transforming (with mfwdtran) each element coordinates to UTM
%                the UTM zone is selected using the mean of the input coords.
%             2) interpolating the now non-rectangularly arranged elements
%                of Arr on a regular, rectangular UTM grid.
%                This is done inside a "maximum inner bounding box"
%                guaranteed to lay inside the projected data.
%
%         CRS of input coordinates is assumed as WGS84.
%
% Syntax: [n,e,ArrUTM,UTMstruct] = FwdRepro(Lat,Lon,Arr,step[,UTMstruct])
%
% Input:
%    Lat  : latitude coordinate vector [m]
%    Lon  : longiute coordinate vector [m]
%    Arr  : rectangularly sampled Lon x Lat array
%            NOTE: transpose accordingly, if needed.
%    step : step between elements in output (ArrUTM) [m]
%    optional UTMstruct: to impose a UTM zone, provide a map projection structure
%                         see 'defaultm' (Matlab builtin) documentation
%
% Output:
%    n         : northing coordinate vector
%    e         : easting coordinate vector
%    ArrUTM    : resampled e x n array
%    UTMstruct : map projection structure of projected data,
%                 see 'defaultm' (Matlab builtin) documentation
%
% 2018, Alberto Pastorutti

narginchk(4,5)
nargoutchk(4,4)

%% Get UTM zone and build mapstruct
if nargin==4
    meanUTMzone = utmzone(mean(Lat),mean(Lon));
    UTMstruct = defaultm('utm');
    UTMstruct.zone = meanUTMzone;
    UTMstruct.geoid = wgs84Ellipsoid;
    UTMstruct = defaultm(UTMstruct);
else
    UTMstruct = varargin{1};
end

%% transform to UTM
[LAT,LON] = meshgrid(Lat,Lon); % Meshgrid from Lat,Lon
[X,Y] = mfwdtran(UTMstruct,LAT,LON);

% transform edges alone, useful in subsequent box crop
% commented part for every edge: trivial, since (Lat,Lon) defines a rectangle
edgeWlon = min(Lon)*ones(1,length(Lat)); % edgeWlat = Lat;
edgeElon = max(Lon)*ones(1,length(Lat)); % edgeElat = Lat;
edgeSlat = min(Lat)*ones(1,length(Lon)); % edgeSlat = Lon;
edgeNlat = max(Lat)*ones(1,length(Lon)); % edgeNlat = Lon;
[edgeWx,~] = mfwdtran(UTMstruct,Lat,edgeWlon);
[edgeEx,~] = mfwdtran(UTMstruct,Lat,edgeElon);
[~,edgeSy] = mfwdtran(UTMstruct,edgeSlat,Lon);
[~,edgeNy] = mfwdtran(UTMstruct,edgeNlat,Lon);

%% build UTM interpolation regular grid
% crop a "maximum inner bounding box" inside the UTM reprojected points
% and round to nearest UTM step towards interior
Wbound = SNIP.RoundToStep(step,max(edgeWx),'ceil');
Ebound = SNIP.RoundToStep(step,min(edgeEx),'floor');
Sbound = SNIP.RoundToStep(step,max(edgeSy),'ceil');
Nbound = SNIP.RoundToStep(step,min(edgeNy),'floor');

% build the UTM rectangular sampling grid
n = Sbound:step:Nbound; % northing vector
e = Wbound:step:Ebound; % easting vector
[N,E] = meshgrid(n,e);

%% interpolate to UTM grid
ScatteredIntObj = scatteredInterpolant(X(:),Y(:),Arr(:),'natural');
ArrUTM = ScatteredIntObj(E,N);

end


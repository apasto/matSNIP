function [Lat,Lon,ArrGEO] = InvRepro(n,e,Arr,UTMstruct,step)
%InvRepro Un-project array from UTM to WGS84 coordinates.
%         this is done by : 1) transforming n, e grid to WGS84 coords
%                           2) interpolating on a regular grid,
%                              in the "maximum inner bounding box"
%         this is done by :
%             0) building a meshgrid for the input array
%             1) transforming (with mfwdtran) each element coordinates to UTM
%                the UTM zone is selected using the mean of the input coords.
%             2) interpolating the now non-rectangularly arranged elements
%                of Arr on a regular, rectangular UTM grid.
%                This is done inside a "maximum inner bounding box"
%                guaranteed to lay inside the projected data.
%
% Syntax: [Lat,Lon,ArrGEO] = InvRepro(n,e,Arr,UTMstruct,step)
%
% Input:
%    n         : northing coordinate vector [m]
%    e         : easting coordinate vector [m]
%    Arr       : rectangularly sampled e x n
%                 NOTE: transpose accordingly, if needed.
%    UTMstruct : map projection structure of projected data,
%                 see 'defaultm' (Matlab builtin) documentation.
%                 Typical usage: UTMstruct kept from FwdRepro output.
%    step      : desired step between elements in output (ArrGEO) [deg]
%
% Output:
%    Lat    : latitude coordinate vector [deg]
%    Lon    : longitude coordinate vector [deg]
%    ArrGEO : resampled Lat x Lon array
%              NOTE: this is transposed in respect to FwdArray input format
%                    (Lon x Lat in that case)
%
% 2018, Alberto Pastorutti

narginchk(5,5)
nargoutchk(3,3)

%% transform: unproject UTM
[N,E] = meshgrid(n,e);
[Y,X] = minvtran(UTMstruct,E,N);

% transform edges alone, useful in subsequent box crop
% commented part for every edge: trivial, since (Lat,Lon) defines a rectangle
edgeWe = min(e)*ones(1,length(n)); % edgeWlat = n;
edgeEe = max(e)*ones(1,length(n)); % edgeElat = n;
edgeSn = min(n)*ones(1,length(e)); % edgeSlat = e;
edgeNn = max(n)*ones(1,length(e)); % edgeNlat = e;
[~,edgeWlon] = minvtran(UTMstruct,edgeWe,n);
[~,edgeElon] = minvtran(UTMstruct,edgeEe,n);
[edgeSlat,~] = minvtran(UTMstruct,e,edgeSn);
[edgeNlat,~] = minvtran(UTMstruct,e,edgeNn);


%% build UTM interpolation regular grid
% crop a "maximum inner bounding box" inside the un-projected points
% and round to nearest geo-coords step towards interior
Wbound = SNIP.RoundToStep(step,max(edgeWlon),'ceil');
Ebound = SNIP.RoundToStep(step,min(edgeElon),'floor');
Sbound = SNIP.RoundToStep(step,max(edgeSlat),'ceil');
Nbound = SNIP.RoundToStep(step,min(edgeNlat),'floor');

% build the geo coords rectangular sampling grid
Lat = Sbound:step:Nbound; % northing vector
Lon = Wbound:step:Ebound; % easting vector
[LON,LAT] = meshgrid(Lon,Lat);

%% interpolate to UTM grid
ScatteredIntObj = scatteredInterpolant(Y(:),X(:),Arr(:),'natural');
ArrGEO = ScatteredIntObj(LAT,LON);

end


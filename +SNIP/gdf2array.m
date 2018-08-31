function OutStruct = gdf2array(InFilename,varargin)
%gdf2array turn a gdf grid into an array with geographic reference
%    Reshape a .gdf file downloaded from ICGEM calculation service
%    http://icgem.gfz-potsdam.de/calcgrid
%    to a lat,lon array.
%    Output a struct containing the reshaped array and reference
%    as lat, lon vectors and lat, lon meshgrid
%    (keeping both vectors and meshgrid is wasteful indeed)
%    The input is scanned for a 'end_of_head' string until row 200.
%
% Syntax: OutStruct = gdf2array(InFilename[,MaxHeaderScan])
%
% Input:
%    InFileName : char vector, path and filename of gdf file
%    [MaxHeaderScan] : scan input file searching for 'end_of_head'
%                      until MaxHeaderScan row (included) is reached
%                      Optional. Default = 200.
%                      This is to prevent the function hanging on
%                      a wrong file, possibily huge.
%
% Output:
%    OutStruct : struct with fields
%                 - val, array of values
%                 - lon (vect)
%                 - lat (vect)
%                 - lonGrid (meshgrid array for val)
%                 - latGrid (meshgrid array for val)
%
% 2018, Alberto Pastorutti

narginchk(1,2)
if nargin==2 && isscalar(varargin{1})
    MaxHeaderScan = varargin{1};
else
    MaxHeaderScan = 200;
end
    

%% scan and import gdf
% Initialize variables and formatspec
delimiter = ' ';
formatSpec = '%f%f%f%[^\n\r]';

fileID = fopen(InFilename,'r');

% Skip to the end of header
isHeaderEnd = false;
HeaderRow = 0;
while isHeaderEnd==false && HeaderRow < (MaxHeaderScan+1) % do not bother going further
    isHeaderEnd = strncmp(fgetl(fileID),'end_of_head',11);
    HeaderRow = HeaderRow+1;
end
if HeaderRow==(MaxHeaderScan+1)
    error(['''end_of_head'' not found in the first ',...
        num2str(MaxHeaderScan,'%.0f'),' rows.'])
end

% Perform textscan
%    'HeaderLines' option set to zero: starting from the header end
dataArray = textscan(fileID, formatSpec, inf,...
    'Delimiter', delimiter, 'MultipleDelimsAsOne', true,...
    'TextType', 'string', 'EmptyValue', NaN,...
    'HeaderLines', 0, 'ReturnOnError', false,...
    'EndOfLine', '\r\n');

fclose(fileID);
ScannedTable = table(dataArray{1:end-1}, 'VariableNames', {'lon','lat','val'});

%% build grid (vectors and meshgrid)
% element order is along x first, increasing, then along y, decreasing
% starting from NW corner (min x, max y)
lonsize = numel(unique(ScannedTable.lon));
latsize = numel(unique(ScannedTable.lat));
lonstep = ScannedTable.lon(2)-ScannedTable.lon(1);
latstep = -(ScannedTable.lat(lonsize+1)-ScannedTable.lat(1));
OutStruct.lon = min(ScannedTable.lon):lonstep:max(ScannedTable.lon);
OutStruct.lat = min(ScannedTable.lat):latstep:max(ScannedTable.lat); % y flipped afterwards
[OutStruct.lonGrid,OutStruct.latGrid] = meshgrid(OutStruct.lon,OutStruct.lat);

%% reshape to array
OutStruct.val = flipud(reshape(ScannedTable.val,lonsize,latsize)');

end




function MapArr = mapLP(MapArr,step,Pcutoff,cutoffval,nanout)
%mapLP lowpass Gaussian filter on image/map (as array)
%      does not need the Image Processing Toolbox
%      uses conv2 if there are no NaNs in input
%      else it reverts to 'nanconv' by Benjamin Kraus
%      available at: https://mathworks.com/matlabcentral/fileexchange/41961-nanconv
%
% Syntax: MapArr = mapLP(MapArr,step,Pcutoff,[cutoffval,nanout])
%
% Inputs:
%    MapArr    : array of map values, assumed regularly sampled in x,y
%    step      : step (distance) between elements in MapArr
%    Pcutoff   : cutoff period of filter
%    cutoffval : response of filter at Pcutoff
%                if only 3 input arguments are given, or if empty
%                default cutoffval = exp(-0.5)
%                (conventional Gaussian cutoff definition)
%    nanout    : argument passed to nanconv
%                either 'nanout' (default here, keeps nan in output)
%                or 'nonanout' (default behaviour of nanconv)
%
% Outputs:
%    MapArr    : filtered input
%
% 2018, Alberto Pastorutti

narginchk(3,5)

if nargin==3
    cutoffval = exp(-0.5);
    nanout = 'nanout';
end
if nargin==4
    nanout = 'nanout';
end
if isempty(cutoffval)
    cutoffval = exp(-0.5);
end

%% Define Gaussian filter
% set Gaussian filter specs
Fsamp   = 1/step; % spatial sampling rate 1/deg
Fsigma  = (sqrt(2*log(1/cutoffval))*Fsamp)/(2*pi*(1/Pcutoff)); % filter standard deviation
FwKs    = 6*Fsigma - 1; % filter kernel size, not rounded
% build Gaussian kernel (square)
[kx,ky] = meshgrid(round(-FwKs/2):round(FwKs/2),...
                   round(-FwKs/2):round(FwKs/2));
F = exp(-kx.^2/(2*Fsigma^2) - ky.^2/(2*Fsigma^2));
F = F./sum(F(:)); % normalized kernel
ks = size(F,1); % kernel size, after rounding

%% Convolve data with filter, for each layer, for depth and rho maps
% convolution is preceded with edge padding
% (by copying edge one kernel size in each direction)

% declare filter function
% Why a function here? This was applied layer-by-layer in LithoLP.
    function Map = ApplyFilt(Map_in)
        % apply edge padding
        Map = zeros(size(Map_in)+2*ks); % preallocate padded matrix
        Map(ks+1:end-(ks),ks+1:end-(ks)) = Map_in; % copy input matrix
        Map(1:ks,ks+1:end-ks) = repmat(Map_in(1,:),ks,1); % copy upper rows
        Map(end-(ks-1):end,ks+1:end-ks) = repmat(Map_in(end,:),ks,1); % copy lower rows
        Map(:,1:ks) = repmat(Map(:,ks+1),1,ks); % copy left cols, incl corner elements
        Map(:,end-(ks-1):end) = repmat(Map(:,end-ks),1,ks); % copy right cols, inlc corner elements
        % perform convolution
        if any(any(isnan(Map_in)))
            Map = nanconv(Map,F,nanout); % requires "nanconv" by Benjamin Kraus
        else
            Map = conv2(Map,F,'same');
        end
        % remove edge padding
        Map(1:ks,:)=[];
        Map(end-(ks-1):end,:)=[];
        Map(:,1:ks)=[];
        Map(:,end-(ks-1):end)=[];
    end

MapArr = ApplyFilt(MapArr);

end


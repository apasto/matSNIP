function out = RoundToStep(step,in,direction)
%RoundToStep round(/floor/ceil) input vector to nearest arbitrary 'step' unit
% digit-counting code comes from this answer by user Jaymin on matlabcentral:
% https://mathworks.com/matlabcentral/answers/10795-counting-the-number-of-digits#answer_68482
% 
% Syntax: out = SNIP.RoundToStep(step,in,[direction])
%
% Inputs:
%    step        : scalar, unit value
%    in          : vector of values to be rounded
%    [direction] : char vector, optional, direction of rounding
%                  'round', 'floor', 'ceil', 'fix'
%                  'round' is default behaviour
%                  case insensitive
%
% Outputs:
%    out         : rounded 'in' vector
%
% 2018, Alberto Pastorutti

% check and manage input
narginchk(2,3)
if nargin==2
    direction='round';
end
assert(isscalar(step),'Argument ''step'' must be a scalar.')
assert(isvector(in),'Argument ''in'' must be a vector.')

% count the number of digits
stepDIG = numel(num2str(step))-numel(strfind(num2str(step),'-'))-numel(strfind(num2str(step),'.'));

% number of zsteps in next power of 10
stepdiv = (10^(stepDIG))/step; 

% round/floor/ceil to step
switch lower(direction)
    case 'round'
        out = ((round((in/(10^(stepDIG)))*stepdiv))/stepdiv)*(10^(stepDIG));
    case 'floor'
        out = ((floor((in/(10^(stepDIG)))*stepdiv))/stepdiv)*(10^(stepDIG));
    case 'ceil'
        out = ((ceil((in/(10^(stepDIG)))*stepdiv))/stepdiv)*(10^(stepDIG));
    case 'fix'
        out = ((fix((in/(10^(stepDIG)))*stepdiv))/stepdiv)*(10^(stepDIG));
    otherwise
        error('Direction (3rd argument) must be either ''round'', ''floor'', ''ceil'', ''fix''');
end

end


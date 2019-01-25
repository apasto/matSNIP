function CC = TileCheckerboard(n, varargin)
%TileCheckerboard creates a checkerboard with arbitrary sized square tiles
%
% Syntax: CC = TileCheckerboard(n, [m, t])
%
%  Create a n-by-m checkerboard array (alternating 1s and 0s),
%  with t-sized square tiles, using xor on a parity map of row/col indices,
%  efficiently applied using bsxfun.
%  The core solution is by MATLABtricks.com (2013, Zoltan Fegyver)
%   matlabtricks.com/post-31/three-ways-to-generate-a-checkerboard-matrix
%   web.archive.org/web/20190125131156/http://matlabtricks.com/post-31/three-ways-to-generate-a-checkerboard-matrix
%  In addition, this implements: - arbitrary cell size (square)
%                                - trim to non-square array size
%  The array is trimmed on the far end.
%  Note: output may need conversion to double to be directly used
%        as input in funtions like 'surf' (while 'mesh' does not fail)
%
%  Input arguments:
%    n   : size of square array
%           if m is given, size along dimension 1
%    optional:
%    m   : size along dimension 2
%    t   : size of square checkerboard tile
%
%  Output arguments:
%    CC  : checkerboard array
%
% 2017, 2018, Alberto Pastorutti

narginchk(1,3)
nargoutchk(0,1)

% manage input arguments
if nargin==3
    m = varargin{1};
    t = varargin{2};
elseif nargin==2
    m = varargin{1};
    t = 1;
else
    t = 1;
end

% get biggests size, using that as size of square array
bigM = max([n, m]);

% parity map for xor, each element repeated m times
% length is rounded up, then trimmed (if mod is nonzero)
pp = repelem(mod(1:ceil(bigM/t),2),t);
if mod(bigM,t)~=0
    pp = pp(1:end-(t-mod(bigM,t)));
end
% pass xor, col, vect
CC = bsxfun(@xor, pp',pp);

% trim to size
if nargin~=0
    CCtrim = CC(1:n,1:m);
    CC = CCtrim;
end

end
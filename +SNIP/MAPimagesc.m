function varargout = MAPimagesc(x, y, c)
%MAPimagesc wrap 'imagesc' to plot a 1:1 aspect, x,y-axis image
%
% Syntax: [figure, axes, image, colorbar](optional) = MAPimagesc(x, y, c)
%
%  Plot a scaled-colour image, directly with 1:1 aspect ratio
%  and origin placed in the bottom left corner.
%  Commonly used as a simple and fast way to check map data
%  on rectangular grids.
%  This is equivalent to calling imagesc(x,y,c), opening plot tools
%  then clicking 'axis image' and 'axis xy' in the image property editor.
%
%  Input arguments:
%    x,y : axis vectors
%    c   : array of image data, with x-axis along rows (dimension 2)
%
%  Output arguments: handles to [figure, axes, image, colorbar]
%   either none or exactly 4 output arguments are allowed
%
% 2018, Alberto Pastorutti

narginchk(3,3)
nargoutchk(0,4)

assert(nargout==0 || nargout==4,'Allowed output arguments: none or 4.');

% Create figure
figureMAP = figure;

% Create axes
axesMAP = axes('Parent',figureMAP);
hold(axesMAP,'on');

% to get correct origin placement, use 'low level' syntax for imagesc
imageMAP = imagesc('XData',x,'YData',y,'CData',c,'Parent',axesMAP);
box(axesMAP,'on');
axis(axesMAP,'tight');
set(axesMAP,'DataAspectRatio',[1 1 1],'Layer','top');
colorbarMAP = colorbar('peer',axesMAP);

% write optional argouts
if nargout==4
    varargout{1} = figureMAP;
    varargout{2} = axesMAP;
    varargout{3} = imageMAP;
    varargout{4} = colorbarMAP;
end

end
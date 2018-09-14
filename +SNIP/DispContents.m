function DispContents()
%DispContents Print out contents of SNIP package.
%
% ** Do not edit DispContents.m **
% Changes will be lost!
% This was automatically created by UpdateCONTENTS.sh
% Header and foot are stored in:
%    readme_template/contents_head
%    readme_template/contents_foot
% while the body (Contents_text) is updated with the functions in +SNIP
Contents_text = "- **FwdRepro** Project array (rectangularly sampled) from WGS84 to UTM coordinates.\n- **gdf2array** turn a gdf grid into an array with geographic reference\n- **getGRDnan** get value at which NaNs are set in Surfer(R) grd format\n- **InvRepro** Un-project array from UTM to WGS84 coordinates.\n- **mapimagesc** wrap 'imagesc' to plot a 1:1 aspect, x,y-axis image\n- **mapLP** lowpass Gaussian filter on image/map (as array)\n- **resampleDH** resample grid to a grid complying to Driscoll and Healy (1994)\n- **RoundToStep** round(/floor/ceil/fix) input vector to nearest arbitrary 'step' unit\n- **SmallCrop** Given two maps, 'Big' and 'Small', crop 'Big' to the extent of 'Small'";
fprintf('\n')
fprintf(Contents_text)
fprintf('\n')

end
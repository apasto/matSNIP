function [Ell_Lat,Ell_Lon,Ell_Height] = sph2ell(Sph_Lat,Sph_Lon,Sph_Height,Ell_Ref,Sph_Ref)
%sph2ell Convert spherical to ellipsoidal coordinates, passing through ECEF
%   [Ell_Lat,Ell_Lon,Ell_Height] = sph2ell(Sph_Lat,Sph_Lon,Sph_Height,Ell_Ref,Sph_Ref)
%       Sph_Lat,Sph_Lon,Sph_Height [degrees, degrees, metres]
%       Ell_Ref : referenceEllipsoid object,
%                  created with referenceEllipsoid
%       Sph_Ref : referenceSphere object,
%                  created with referenceSphere

narginchk(5,5)
nargoutchk(3,3)

[x,y,z] = geodetic2ecef(Sph_Ref,Sph_Lat,Sph_Lon,Sph_Height);
[Ell_Lat,Ell_Lon,Ell_Height] = ecef2geodetic(Ell_Ref,x,y,z);

end


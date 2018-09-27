function [Sph_Lat,Sph_Lon,Sph_Height] = ell2sph(Ell_Lat,Ell_Lon,Ell_Height,Ell_Ref,Sph_Ref)
%ell2sph Convert ellipsoidal to spherical coordinates, passing through ECEF
%   [Sph_Lat,Sph_Lon,Sph_Height] = ell2sph(Ell_Lat,Ell_Lon,Ell_Height,Ell_Ref,Sph_Ref)
%       Ell_Lat,Ell_Lon,Ell_Height [degrees, degrees, metres]
%       Ell_Ref : referenceEllipsoid object,
%                  created with referenceEllipsoid
%       Sph_Ref : referenceSphere object,
%                  created with referenceSphere

narginchk(5,5)
nargoutchk(3,3)

[x,y,z] = geodetic2ecef(Ell_Ref,Ell_Lat,Ell_Lon,Ell_Height);
[Sph_Lat,Sph_Lon,Sph_Height] = ecef2geodetic(Sph_Ref,x,y,z);

end


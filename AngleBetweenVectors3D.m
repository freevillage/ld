function theta = AngleBetweenVectors3D( a, b )

theta = atan2(norm(cross(a,b)), dot(a,b));

end
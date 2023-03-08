module SolarGeometry

using Dates: DateTime, datetime2julian, year, month, day, hour, minute, second

export solar_azimuth_altitude



"""
    function solar_azimuth_altitude(utc_time, lat, lon, alt)

Given a UTC time `utc_time`, latitude `lat`, longitude `lon`, and altitutde `alt`, return the solar azimuth and solar elevation angles (in degrees) relative to that location.


This is a Julia (re)implementation of the Matlab script by Darin C. Koblick [(link)](https://www.mathworks.com/matlabcentral/fileexchange/23051-vectorized-solar-azimuth-and-elevation-estimation).

Other references:
- [http://stjarnhimlen.se/comp/tutorial.html#5](http://stjarnhimlen.se/comp/tutorial.html#5)
- [http://www.stargazing.net/kepler/altaz.html](http://www.stargazing.net/kepler/altaz.html)
"""
function solar_azimuth_altitude(UTC::DateTime, Lat, Lon, Alt)
    jd = datetime2julian(UTC)
    d  =  jd - 2451543.5

    # Keplerian Elements for the Sun (geocentric)
    w = 282.9404 + 4.70935e-5 * d #(longitude of perihelion degrees)
    # a = 1.000000              #(mean distance, a.u.)
    e = 0.016709 - 1.151e-9 *d  # (eccentricity)
    M = mod(356.0470+0.9856002585 * d,360) #   (mean anomaly degrees)
    L = w + M  # (Sun's mean longitude degrees)

    oblecl = 23.4393-3.563e-7 * d  # (Sun's obliquity of the ecliptic)

    # auxiliary angle
    E = M+(180/pi) * e * sin(M*π/180)*(1+e*cos(M*π/180))

    # rectangular coordinates in the plane of the ecliptic (x axis toward perhilion)
    x = cos(E*π/180)-e
    y = sin(E*π/180)*sqrt(1-e^2)

    # find the distance and true anomaly
    r = sqrt(x^2 + y^2)
    v = atan(y,x) * (180/π)

    # find the longitude of the sun
    lon = v + w

    # compute the ecliptic rectangular coordinates
    xeclip = r * cos(lon*π/180)
    yeclip = r * sin(lon*π/180)
    zeclip = 0.0

    # rotate these coordinates to equitorial rectangular coordinates
    xequat = xeclip
    yequat = yeclip*cos(oblecl*π/180) + zeclip*sin(oblecl*π/180)
    zequat = yeclip*sin(oblecl*π/180) +zeclip*cos(oblecl*π/180)

    # convert equatorial rectangular coordinates to RA and Decl:
    r = sqrt(xequat^2 + yequat^2 + zequat^2)-(Alt/149598000) # roll up the altitude correction
    RA = atan(yequat,xequat)*180/π
    delta = asin(zequat/r)*(180/π)

    # Following the RA DEC to Az Alt conversion sequence explained here:
    # http://www.stargazing.net/kepler/altaz.html

    # Find the J2000 value
    J2000 = jd - 2451545.0
    UTH = hour(UTC) + minute(UTC)/60 + second(UTC)/3600

    # Calculate local siderial time
    GMST0=mod(L+180,360)/15

    SIDTIME = GMST0 + UTH + Lon./15;

    # Replace RA with hour angle HA
    HA = (SIDTIME*15 - RA)

    # convert to rectangular coordinate system
    x = cos(HA*π/180)*cos(delta*π/180)
    y = sin(HA*π/180)*cos(delta*π/180)
    z = sin(delta*π/180)

    # rotate this along an axis going east-west.
    xhor = x*cos((90-Lat)*π/180) - z*sin((90-Lat)*π/180)
    yhor = y
    zhor = x*sin((90-Lat)*π/180) + z*cos((90-Lat)*π/180)

    # Find the h and AZ
    Az = atan(yhor,xhor)*180/π + 180
    El = asin(zhor)*180/π

    return Az, El
end



"""
    function solar_azimuth_altitude(Δt, start_time::DateTime, lat, lon, alt)

Given a UTC time `start_time`, latitude `lat`, longitude `lon`, altitutde `alt` and offset `Δt`, return the solar azimuth and solar elevation angles (in degrees) relative to that location at `start_time + Δt`. This version of the function is to enable users to generate continuous output since DateTime does not allow for infinite precision seconds.
"""
function solar_azimuth_altitude(Δt, UTC::DateTime, Lat, Lon, Alt)
    jd = datetime2julian(UTC)
    d  =  jd - 2451543.5

    # Keplerian Elements for the Sun (geocentric)
    w = 282.9404 + 4.70935e-5 * d #(longitude of perihelion degrees)
    # a = 1.000000              #(mean distance, a.u.)
    e = 0.016709 - 1.151e-9 *d  # (eccentricity)
    M = mod(356.0470+0.9856002585 * d,360) #   (mean anomaly degrees)
    L = w + M  # (Sun's mean longitude degrees)

    oblecl = 23.4393-3.563e-7 * d  # (Sun's obliquity of the ecliptic)

    # auxiliary angle
    E = M+(180/pi) * e * sin(M*π/180)*(1+e*cos(M*π/180))

    # rectangular coordinates in the plane of the ecliptic (x axis toward perhilion)
    x = cos(E*π/180)-e
    y = sin(E*π/180)*sqrt(1-e^2)

    # find the distance and true anomaly
    r = sqrt(x^2 + y^2)
    v = atan(y,x) * (180/π)

    # find the longitude of the sun
    lon = v + w

    # compute the ecliptic rectangular coordinates
    xeclip = r * cos(lon*π/180)
    yeclip = r * sin(lon*π/180)
    zeclip = 0.0

    # rotate these coordinates to equitorial rectangular coordinates
    xequat = xeclip
    yequat = yeclip*cos(oblecl*π/180) + zeclip*sin(oblecl*π/180)
    zequat = yeclip*sin(oblecl*π/180) +zeclip*cos(oblecl*π/180)

    # convert equatorial rectangular coordinates to RA and Decl:
    r = sqrt(xequat^2 + yequat^2 + zequat^2)-(Alt/149598000) # roll up the altitude correction
    RA = atan(yequat,xequat)*180/π
    delta = asin(zequat/r)*(180/π)

    # Following the RA DEC to Az Alt conversion sequence explained here:
    # http://www.stargazing.net/kepler/altaz.html

    # Find the J2000 value
    J2000 = jd - 2451545.0
    UTH = hour(UTC) + minute(UTC)/60 + (second(UTC) + Δt)/3600 # <-- add offset of Δt seconds converted to hours.

    # Calculate local siderial time
    GMST0=mod(L+180,360)/15

    SIDTIME = GMST0 + UTH + Lon./15;

    # Replace RA with hour angle HA
    HA = (SIDTIME*15 - RA)

    # convert to rectangular coordinate system
    x = cos(HA*π/180)*cos(delta*π/180)
    y = sin(HA*π/180)*cos(delta*π/180)
    z = sin(delta*π/180)

    # rotate this along an axis going east-west.
    xhor = x*cos((90-Lat)*π/180) - z*sin((90-Lat)*π/180)
    yhor = y
    zhor = x*sin((90-Lat)*π/180) + z*cos((90-Lat)*π/180)

    # Find the h and AZ
    Az = atan(yhor,xhor)*180/π + 180
    El = asin(zhor)*180/π

    return Az, El
end





end

"""Welche Versionen von GEOS, PROJ und GDAL stecken in meinem Python-Geostack?"""
import geopandas
import pyogrio
import pyproj
import rasterio
import shapely

print("geopandas:      ", geopandas.__version__)
print("GEOS (shapely): ", shapely.geos_version_string)
print("PROJ (pyproj):  ", pyproj.proj_version_str)
print("GDAL (pyogrio): ", pyogrio.__gdal_version_string__)
print("GDAL (rasterio):", rasterio.__gdal_version__)
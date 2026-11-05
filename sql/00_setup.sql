-- 00_setup.sql
-- Phase 0: Lerndatenbank einrichten und PostGIS prüfen
--
-- Voraussetzung: Datenbank "lernen" existiert.
-- (Per Klick in pgAdmin angelegt. Gleichwertig in SQL, ausgeführt in der
--  Datenbank "postgres":  CREATE DATABASE lernen;)
-- Dieses Skript im Query Tool der Datenbank "lernen" ausführen.

-- 1. PostGIS in dieser Datenbank aktivieren (einmal pro Datenbank)
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Kontrolle: richtige Datenbank? Welche GEOS-, PROJ- und GDAL-Versionen?
SELECT current_database();
SELECT postgis_full_version();

-- 3. Puffer-Experiment: Kreis mit Radius 1 als Vieleck angenähert
--    PostGIS-Standard: 8 Segmente pro Viertelkreis, Shapely-Standard: 16
SELECT ST_Area(ST_Buffer(ST_Point(0, 0), 1))                 AS postgis_standard,
       ST_Area(ST_Buffer(ST_Point(0, 0), 1, 'quad_segs=16')) AS wie_shapely,
       pi()                                                  AS kreis_exakt;
-- Ergebnis: postgis_standard = ...   wie_shapely = ...
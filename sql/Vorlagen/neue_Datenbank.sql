-- neue_datenbank.sql
-- Grundgerüst für eine neue Geodatenbank.
-- Vorher: Datenbank anlegen (in pgAdmin oder mit CREATE DATABASE name;).
-- Dann dieses Skript im Query Tool der NEUEN Datenbank ausführen.

-- 0. Kontrolle: Bin ich in der richtigen Datenbank?
SELECT current_database();

-- 1. PostGIS: Geometrietyp, ST_-Funktionen, räumliche Indizes
CREATE EXTENSION IF NOT EXISTS postgis;

-- 2. Nur bei Bedarf einkommentieren:
-- CREATE EXTENSION IF NOT EXISTS postgis_raster;    -- Rasterdaten in der Datenbank
-- CREATE EXTENSION IF NOT EXISTS postgis_topology;  -- Topologie

-- 3. Kontrolle der Versionen
SELECT postgis_lib_version(), postgis_geos_version(), postgis_proj_version();

-- Kommt in Phase 1 dazu: Schemas (Modul 37), Rollen und Rechte (36),
-- Bearbeitungshistorie per Trigger (34)
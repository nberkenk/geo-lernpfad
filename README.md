# geo-lernpfad

Mein Lern-Repository auf dem Weg zum Geospatial-Profi:
SQL/PostGIS, Python-Geostack, cloud-native Fernerkundung, GeoAI.
Alle Übungen nutzen ausschließlich offene Daten.

## Inhalt

| Ordner | Inhalt |
|---|---|
| `sql/` | SQL-Übungen für PostgreSQL/PostGIS |
| `scripts/` | Python-Skripte |
| `notebooks/` | Jupyter-Notebooks für Analysen und Berichte |
| `data/` | Lokale Daten, nicht im Repository (Quellen stehen in den jeweiligen Übungen) |

## Einrichtung

Voraussetzungen: Git, [uv](https://docs.astral.sh/uv/), PostgreSQL 18 mit PostGIS.

```powershell
git clone https://github.com/DEINNAME/geo-lernpfad.git
cd geo-lernpfad
uv sync
uv run jupyter lab
```

Datenbank: In PostgreSQL eine Datenbank `lernen` anlegen und
`sql/00_setup.sql` im Query Tool dieser Datenbank ausführen.

## Gleiche Bibliotheken, verschiedene Versionen

QGIS, Python und PostGIS rechnen alle mit GEOS (Geometrie), PROJ
(Koordinatentransformation) und GDAL (Formate), aber jeweils in eigenen Versionen:

|                                                | GEOS   | PROJ  | GDAL            |
|------------------------------------------------|--------|-------|-----------------|
| Python (shapely / pyproj / pyogrio / rasterio) | 3.14.1 | 9.8.1 | 3.12.4 / 3.12.2 |
| PostGIS 3.6.2 (`postgis_full_version()`)       | 3.14.1 | 8.2.1 | 3.9.2           |
| QGIS 3.44.12 (Hilfe → Über)                    | 3.14.1 | 9.8.1 | 3.13.1          |

Folge: Dieselbe Operation kann je nach Werkzeug leicht abweichen. Beispiel Puffer
mit Radius 1: PostGIS-Standard ... , Shapely-Standard ... , exakter Kreis 3,14159.

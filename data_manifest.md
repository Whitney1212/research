# Data Manifest

This repository contains project memory and governance material, but some source files and generated outputs live outside the repo.

## In-repo content

### Project memory
- `project_memory/`

### Research context
- `regov_memory/`

### Skill package
- `regov_build/regov/`

### Dashboards
- `regov_dashboard/`

### Analysis summaries and plans
- `analysis_snapshot.md`
- `repo_index.md`
- `next_step/`

## External source locations

These paths are external local research storage used by the project. The repository records their role and provenance, but does not copy the underlying source data.

### Raw data coverage
- `E:\Dataset_RAW\数据存入-处理记录.xlsx`
  Main raw-data coverage workbook. Known sheets include `MT_EC`, `MT_AP`, `MT_MET`, `CVT_MET`, `CVT_EC`, `CVT_AP`, `Flares_EC`, `Flares_AP`, and `Flares_MET`.
- `E:\Dataset_RAW\20260428数据甘特图.png`
  Raw-data coverage Gantt-style visual summary.
- `E:\Dataset_RAW\现有数据.xlsx`
  Additional workbook found in the raw-data directory; not yet treated as the main manifest source.

### Core analysis roots
- `D:\00 博士阶段\博一\05 Project\com_260507`
- `D:\00 博士阶段\博一\05 Project\com_260326`
- `D:\00 博士阶段\博一\05 Project\com_rotation`
- `D:\00 博士阶段\博一\05 Project\com_3sites_horizontal`
- `D:\00 博士阶段\博一\05 Project\com_mass_balance`
- `D:\00 博士阶段\博一\05 Project\ecpreproc`

### Important external result families
- `com_260507\COMPUTE\EA_com\EA_flux_results.csv`
  Main covariance-style EA / EC result set.
- `com_260507\COMPUTE\EA_com\EA_raw_w_total_transport`
  raw-`w` CO2 total transport branch.
- `com_260507\COMPUTE\EA_com\EA_raw_w_up_down_airmass_details`
  up/down air-mass and concentration-anomaly decomposition.
- `com_260507\COMPUTE\EA_com\EA_timeline_alignment`
  CO2 event alignment, profile-switch timing, and mechanism visualization tables.
- `com_rotation\results`
  fixed-station rotation sensitivity outputs for `none`, `dr`, `pf`, and `spf`.
- `com_3sites_horizontal\OUTPUT`
  three-site horizontal wind, north-offset coordinate harmonization, and FL motion correction outputs.
- `com_mass_balance`
  FL moving-transect anomaly transport and pass / position-time diagnostics.

## How to use this manifest

When a note, figure, or verification file depends on external data:
1. identify the source script
2. identify the generated output
3. record the local path in the corresponding verification note
4. keep a short description in the repo so the dependency is visible

## Suggested convention

For every important analysis result, keep these three items linked:
- the script that produced it
- the verification note that validated it
- the output file or figure path

## Do not copy

Do not copy large raw data, high-frequency matched tables, or generated figure batches into this repository unless explicitly needed. Keep the repository as a readable memory, provenance, and coordination layer.

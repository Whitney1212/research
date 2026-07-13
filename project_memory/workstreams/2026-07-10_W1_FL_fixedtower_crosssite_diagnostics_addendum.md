# 2026-07-10 W1 Addendum: FL and FixedTower Cross-site Diagnostics

## Goal

Record the minimum-path diagnostics added after the formal delivery of full FL `EC_ecpreproc`, without rewriting the main `W1_EA_EC_flux.md` file.

## What Was Added

- backfilled a fixed-tower-style FL common-period raw `sigma_co2` table and diurnal figure
- added FL full-product diurnal diagnostics for `sigma_co2`, `sigma_w`, mean wind speed, and `w_mean`
- added cross-site comparison figures for `MT / CVT / FL`

## Key Outputs

FL derived diagnostics:

- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_sigma_co2_raw_common_periods_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_sigma_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_sigma_w_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_wind_speed_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_wmean_diurnal.png`

Cross-site outputs:

- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\figures\three_site_sigma_co2_common_periods.png`
- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\figures\three_site_wmean_no_rotation_pf.png`

## Caliber Notes

- `three_site_sigma_co2_common_periods` uses common-period raw `sigma_co2`.
- `three_site_wmean_no_rotation_pf` uses two fixed facets:
  - `No rotation`
  - `PF`, defined as `MT/CVT sector_pf + FL PF_8bin_2ensemble (BPF)`

## Verification

- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_fl_raw_sigma_co2_common_periods.md`
- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_three_site_sigma_co2_common_periods.md`
- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_three_site_wmean_no_rotation_pf.md`

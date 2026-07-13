# 2026-07-10 FL / FixedTower Cross-site Progress Update

## Scope

This addendum records the 2026-07-10 progress around:

- FL full `EC_ecpreproc` derived diagnostics
- FL common-period raw `sigma_co2` backfill aligned to the fixed-tower comparison caliber
- cross-site comparison figures combining `MT / CVT / FL`

This file is an incremental runtime note added without rewriting older aggregate memory files.

## New Data Products

- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_diurnal_plot_data.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_sigma_co2_raw_common_periods_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_sigma_co2_raw_common_periods_summary.txt`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_sigma_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_sigma_diurnal_plot_data.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_sigma_w_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_sigma_w_diurnal_plot_data.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_wind_speed_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_wind_speed_diurnal_plot_data.csv`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\figures_diurnal\FL_full_ec_wmean_diurnal.png`
- `E:\Dataset_Level1\Flares\EC_ecpreproc\FL_full_ec_wmean_diurnal_plot_data.csv`

## New Cross-site Comparison Outputs

- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\figures\three_site_sigma_co2_common_periods.png`
- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_sigma_co2_common_periods_plot_data.csv`
- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_sigma_co2_common_periods_summary.txt`
- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\figures\three_site_wmean_no_rotation_pf.png`
- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_wmean_no_rotation_pf_plot_data.csv`
- `E:\Dataset_Level1\FixedTower\EC\rotation_comparison_with_FL\three_site_wmean_no_rotation_pf_summary.txt`

## Interpretation Boundary

- The fixed-tower common-period `sigma_co2` comparison is based on raw/common-period CO2 variability and is not method-specific.
- The FL full-product `scalar_sd` can vary by processing method because it is tied to method-specific delivered windows and QC.
- The FL common-period raw `sigma_co2` product was created specifically to make FL comparable to the fixed-tower common-period raw `sigma_co2` product.
- In the cross-site `w_mean` figure, the two facets are fixed as `No rotation` and `PF`.
- The `PF` facet uses `MT/CVT sector_pf + FL PF_8bin_2ensemble (BPF)` as the operational comparison caliber.

## Verification References

- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_fl_full_ec_sigma_diurnal.md`
- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_fl_raw_sigma_co2_common_periods.md`
- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_three_site_sigma_co2_common_periods.md`
- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_fl_full_ec_wind_speed_diurnal.md`
- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_fl_full_ec_wmean_diurnal.md`
- `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-10_three_site_wmean_no_rotation_pf.md`

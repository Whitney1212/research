# 2026-07-21 FL no-rotation pass air accumulation

## Scope and processing boundary

- Independently completed the full-pass no-rotation air-accumulation product while BPF work was separate. It uses `w_no_rotation = Uz`; it does not rotate coordinates, subtract `w_mean`, use CO2/H2O/IRGA QC, calculate covariance, apply lag, position-bin, or gapfill.
- Input passes came from `E:\FL_MASSBALANCE\202308\downstream_multicaliber\bundle_index.csv`. `main_complete` has priority, oldcode fills only main-absent physical intervals, and `batch_b_complete` remains a separate `0_230_m` track. The retained inventory is 5,177 physical passes. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\no_rotation_pass_inventory.csv`; `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\no_rotation_duplicate_pass_audit.csv`]
- Bundle timestamps with a trailing `Z` are interpreted as historical local-wall-clock labels so they align with TOA5 `Asia/Shanghai` time; TOA5 `24:00:00.x` advances to the next local date. Wind QC is `diag_sonic == 0`, finite `Ux/Uy/Uz`, `abs(Ux/Uy) <= 30 m s^-1`, horizontal speed `<= 45 m s^-1`, `abs(Uz) <= 10 m s^-1`, then Vickers-Mahrt on each complete pass (`5 sigma`, run length `<= 3`, linear interpolation, maximum 20 iterations, pass length / 6 window). [verified: `D:\00 博士阶段\99 Project\06 EA\scripts\run_fl_no_rotation_pass_air_accumulation.R`; `E:\Dataset_Level1\Flares\Eddy Accumulation\no_rotation_manifest.txt`]

## Verified result

- All 22 pass-start months completed and passed the final UID, monthly-progress, finite-value, sign, track/direction, and closure checks. Of 5,177 inventory passes, 4,662 have `qc_status=ok` and 515 remain as explicit failed rows. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\no_rotation_pass_air_accumulation_all.csv`; `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\no_rotation_monthly_progress.csv`]
- Failure reasons are `no_diag_sonic_zero=428`, `no_raw_file=65`, and `no_samples_in_pass=22`. These do not alter `strict_complete`; they are only this product's high-frequency wind-QC status. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\no_rotation_summary.txt`]
- The maximum absolute closure error is `2.27373675443232e-13 m`, satisfying the requested tolerance. `Q_down_m` is stored as a positive downward amount. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\no_rotation_closure_audit.csv`]

## Deliverables and next boundary

- Formal runner: `D:\00 博士阶段\99 Project\06 EA\scripts\run_fl_no_rotation_pass_air_accumulation.R`; delivery copy: `E:\Dataset_Level1\Flares\Eddy Accumulation\scripts\run_fl_no_rotation_pass_air_accumulation.R`.
- Main tables: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\no_rotation_pass_air_accumulation_all.csv`, `no_rotation_diurnal_30min_preliminary.csv`, and the preserved monthly tables.
- This is an air-motion baseline, not a CO2 transport or BPF comparison result. The next paired analysis must use the same sample-QC routine, match common pass/sample support with the accepted BPF product, preserve `0_245_m` and `0_230_m` separately, then apply any final diurnal screen without redefining the source pass inventory. [inference: task boundary and retained QC design]

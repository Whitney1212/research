# 2026-07-13 fixed-tower common four-method exchange diagnostics rerun

## Scope

- Towers: `MT`, `CVT`; year: `2025`; strict NEE workflow.
- Rotation methods: `no_rotation`, `dr`, `global_pf`, `sector_pf`.
- Per-window fields: `sigma_w`, `sigma_c`, `rwc`, `Fc = mean(w'c')`, `Fneg = mean(q | q < 0)`, `Fpos = mean(q | q > 0)`.

## Repair and final window rule

- The fast Level0 reader now treats `-99999` / `-99999.0` CO2 values as missing.
- Final rows retain only timestamps that are `valid_final == TRUE` for all four methods **and** have finite values for all six diagnostics under every method. This replaces the previous output tables, which retained some NEE-common timestamps without a raw diagnostic row.

## Verification

- MT: `3923` complete common windows; four method tables each have `3923` rows and `0` incomplete rows.
- CVT: `2089` complete common windows; four method tables each have `2089` rows and `0` incomplete rows.
- Excluded from the NEE-common sets because raw diagnostics were unavailable/incomplete: MT `64` of `3987`; CVT `32` of `2121`.

## Compact result

- MT mean `sigma_w = 0.601-0.633 m s^-1`, `sigma_c = 0.897 ppm`, `rwc = -0.153 to -0.167`, and `Fc = -0.128 to -0.143` in raw `w'c'` units.
- CVT mean `sigma_w = 0.566-0.601 m s^-1`, `sigma_c = 1.180 ppm`, `rwc = -0.096 to -0.104`, and `Fc = -0.068 to -0.072` in raw `w'c'` units.
- Both towers have negative mean covariance; the MT covariance magnitude is consistently larger. `sigma_c` is rotation-invariant by definition and no longer carries the MT sentinel-value artifact.

## Deliverables

- Script: `D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_four_method_exchange_diagnostics_2025.R`
- Outputs: `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025\{no_rotation,dr,global_pf,sector_pf}` and `E:\Dataset_Level1\CVT\EC\whole year computation\rotation_sensitivity_standardized_2025\{no_rotation,dr,global_pf,sector_pf}`.

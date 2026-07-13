# 2026-07-13 fixed-tower sigma_c handoff

## One-line status

`MT sigma_c` has been rechecked enough to conclude that the current mean `11.51` is not credible; it is inflated by raw `CO2 = -99999` sentinel points that were not treated as missing in the fast diagnostics reader.

## What is already done

- common four-method exchange diagnostics were generated under each method directory for `MT` and `CVT`
- the diagnostics script was updated so `-99999` and `-99999.0` are now treated as missing in the fast TOA5 subset reader
- a targeted recheck of `sigma_c` on the existing common windows was completed
- corrected summary CSVs were written to:
  - `C:\Users\admin\.codex\visualizations\2026\07\12\019f5658-5105-7383-b7e0-dad15240aad7\sigma_c_recheck_targeted_summary.csv`
  - `C:\Users\admin\.codex\visualizations\2026\07\12\019f5658-5105-7383-b7e0-dad15240aad7\sigma_c_recheck_targeted_hourly.csv`
  - `C:\Users\admin\.codex\visualizations\2026\07\12\019f5658-5105-7383-b7e0-dad15240aad7\sigma_c_recheck_targeted_extremes.csv`

## Bottom-line findings to carry into the new window

- corrected `MT sigma_c` median: `0.8099555`
- corrected `CVT sigma_c` median: `0.9269313`
- corrected `MT sigma_c` mean: `0.8967565`
- corrected `CVT sigma_c` mean: `1.1802876`
- `MT` contaminated windows identified: `53`
- `CVT` contaminated windows identified: `0`

Interpretation:

- do **not** use the old `MT sigma_c` mean `11.51`
- current evidence does **not** support saying `MT` has stably stronger concentration heterogeneity than `CVT`

## Files/scripts that matter

- main diagnostics script:
  - `D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_four_method_exchange_diagnostics_2025.R`
- targeted recheck helper:
  - `D:\00 博士阶段\99 Project\06 EA\scripts\tmp_sigma_c_recheck_targeted_2025.R`
- formal memory record:
  - `D:\00 博士阶段\99 Project\06 EA\project_memory\evidence\verifications\2026-07-13_fixed_tower_sigma_c_recheck_mt_cvt.md`

## What the next window should do

If the goal is just scientific interpretation:

- use the corrected `sigma_c` summary from the targeted recheck
- treat the old `MT` diagnostics `sigma_c` values as contaminated

If the goal is to repair deliverables:

- rerun `MT` only
- overwrite the four common-method diagnostics under:
  - `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025\no_rotation`
  - `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025\dr`
  - `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025\global_pf`
  - `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025\sector_pf`
- recompute not only `sigma_c` but also `rwc`, `Fc`, `Fneg`, and `Fpos`, because they all depend on the same raw `co2`

## Runtime expectation if MT overwrite rerun is chosen

- about `1.5` hours for `MT`

## Background process note

An older broad-scan `Rscript` recheck process may still be running in the background from this window. It is not needed for the decision above and does not block opening a new window.

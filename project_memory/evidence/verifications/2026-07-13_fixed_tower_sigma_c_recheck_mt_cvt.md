# 2026-07-13 fixed-tower sigma_c recheck for MT and CVT

## Goal

Recheck whether the very large `MT sigma_c` mean (`11.51`) from the common four-method exchange-diagnostics table is physically credible, or whether it is mainly inflated by a small number of bad high-frequency windows.

## Scope

- Focus tower pair: `MT` and `CVT`
- Base result files: the current `no_rotation` common-window diagnostics
  - `E:\Dataset_Level1\MT\EC\whole year computation\rotation_sensitivity_standardized_2025\no_rotation\MT_common_four_method_valid_window_exchange_diagnostics_2025.csv`
  - `E:\Dataset_Level1\CVT\EC\whole year computation\rotation_sensitivity_standardized_2025\no_rotation\CVT_common_four_method_valid_window_exchange_diagnostics_2025.csv`
- Window set: the existing common four-method valid half-hours
- Recheck target: `sigma_c` only

## Root cause

The current `MT sigma_c` mean of `11.51` is not trustworthy.

Raw-window spot checks showed that extreme `MT` windows contained sentinel values `-99999` in the raw `CO2` stream. The fast subset reader used in the common-window diagnostics script initially treated `-9999` as missing but did **not** treat `-99999` as missing. As a result, a few windows were inflated to characteristic false `sigma_c` levels around `748`, `1058`, and `1296`.

Confirmed examples:

- `2025-02-28 15:30:00` in `TOA5_14893.Time_Series_420_2025_02_28_0000.dat`
  - raw `CO2` contains `3` points equal to `-99999`
  - original table `sigma_c = 1296.5631`
- `2025-02-28 09:30:00` in the same file
  - raw `CO2` contains `2` points equal to `-99999`
  - original table `sigma_c = 1058.7449`

These are not plausible concentration-heterogeneity windows; they are data-quality artifacts.

## Code status

The diagnostics script was updated so the fast TOA5 reader now also treats `-99999` and `-99999.0` as missing:

- script: `D:\00 博士阶段\99 Project\06 EA\scripts\compute_fixed_tower_common_four_method_exchange_diagnostics_2025.R`
- the `na.strings` list now includes `-99999` and `-99999.0`
- `sigma_c` is still computed as `sd(co2)` within each 30 min block

## Recheck outputs

Targeted recheck outputs were written to:

- `C:\Users\admin\.codex\visualizations\2026\07\12\019f5658-5105-7383-b7e0-dad15240aad7\sigma_c_recheck_targeted_summary.csv`
- `C:\Users\admin\.codex\visualizations\2026\07\12\019f5658-5105-7383-b7e0-dad15240aad7\sigma_c_recheck_targeted_hourly.csv`
- `C:\Users\admin\.codex\visualizations\2026\07\12\019f5658-5105-7383-b7e0-dad15240aad7\sigma_c_recheck_targeted_extremes.csv`

Helper script used for the targeted recheck:

- `D:\00 博士阶段\99 Project\06 EA\scripts\tmp_sigma_c_recheck_targeted_2025.R`

## Corrected sigma_c summary

### MT

- windows: `3923`
- median: `0.8099555`
- `25% - 75%`: `0.5214125 - 1.2056580`
- `95%`: `1.7731200`
- `99%`: `2.2749530`
- maximum: `5.1878830`
- mean: `0.8967565`
- mean excluding top `1%`: `0.8756783`
- contaminated windows identified and corrected: `53`
- original mean before correction: `11.5109960`
- original median before correction: `0.8157784`

### CVT

- windows: `2089`
- median: `0.9269313`
- `25% - 75%`: `0.6091374 - 1.4078770`
- `95%`: `3.0631800`
- `99%`: `4.9507500`
- maximum: `9.5331990`
- mean: `1.1802876`
- mean excluding top `1%`: `1.1267253`
- contaminated windows identified: `0`

## Interpretation

- The previously quoted `MT sigma_c = 11.51` mean was dominated by bad raw points and must not be used as evidence of persistent stronger concentration heterogeneity at `MT`.
- After correction, `MT` is **not** higher than `CVT` in central tendency. `MT` median and high quantiles are both lower than `CVT`.
- Therefore the current evidence does **not** support a stable statement that `MT` has stronger `CO2` concentration heterogeneity than `CVT`.

## Hourly pattern

- `MT` hourly median `sigma_c` ranges from about `0.345` to `1.175`
  - minimum median hour: `18`
  - maximum median hour: `11`
- `CVT` hourly median `sigma_c` ranges from about `0.692` to `1.203`
  - minimum median hour: `16`
  - maximum median hour: `0`

For `MT`, contaminated windows are concentrated in a subset of hours, especially around local midday to afternoon, with the highest count at hour `15`.

## Comparability checks

### CO2 unit

Both metadata files declare the scalar input unit for `co2` as `ppm`.

- `D:\00EDDYPRO\sh_MT.metadata`
  - `col_8_variable=co2`
  - `col_8_unit_in=ppm`
- `D:\00EDDYPRO\CVT_EC_for_EddyPro.metadata`
  - `col_8_variable=co2`
  - `col_8_unit_in=ppm`

The raw TOA5 header uses `umolCO2 mol-1`, which is equivalent to `ppm`.

### Raw sampling frequency

- `MT`: `10 Hz`
- `CVT`: `20 Hz`

### Instrument metadata

Both towers list:

- sonic: `csat3_1`
- scalar instrument: `generic_closed_path_1`

Tube metadata are similar but not identical:

- `MT`: `tube_length=64.5`, `tube_diameter=2.1`, `tube_flowrate=6.00`
- `CVT`: `tube_length=64.5`, `tube_diameter=2.2`, `tube_flowrate=6.00`

No explicit scalar range information was found in these metadata files.

### Same concentration field?

Conceptually yes, but raw column names differ:

- `MT`: raw field read from `CO2`
- `CVT`: raw field read from `CO2_mixratio`

The diagnostics script maps both to the same internal scalar column `co2`.

### Same preprocessing stage?

Yes for the diagnostics product.

In the current common-window diagnostics script:

- `sigma_c` is computed from `dfp$co2` inside the 30 min block
- `rwc`, `Fc`, `Fneg`, and `Fpos` use `co2_prime`
- this happens after block creation and rotation-related setup for the window
- but the scalar variance itself is still the block SD of `co2`

### Despiking

For this diagnostics product, no despiking is currently applied before `sigma_c` calculation.

The `ecpreproc` package has Vickers-Mahrt despiking functions, but this script does not call them.

## Consequence for downstream fields

The same bad `CO2` points that inflate `sigma_c` also affect:

- `rwc`
- `Fc`
- `Fneg`
- `Fpos`

Therefore, if these fields are to be interpreted for `MT`, they should also be recomputed after the `-99999` missing-value fix. `CVT` does not need this correction for the same reason.

## Recommended next step

For a formal overwrite rerun:

- rerun `MT` only
- overwrite all four common-method diagnostics (`no_rotation / dr / global_pf / sector_pf`)
- recompute `sigma_c`, `rwc`, `Fc`, `Fneg`, and `Fpos`
- no need to rerun `CVT` for this specific issue

Estimated runtime discussed in-thread:

- `MT`: about `1.5` hours
- `CVT`: about `2.3` hours
- both towers together: about `4` hours

## Handoff note

At the time this note was written, an earlier broad-scan R recheck process was still running in the background, but the targeted recheck above was sufficient to establish the root cause and corrected summary. A new window does not need to wait for that broad-scan process before deciding whether to formally overwrite `MT` diagnostics.

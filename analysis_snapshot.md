# Analysis Snapshot

This file collects the current stable results that are most useful for downstream analysis and for model-assisted reading of the repository.

Last repository-level update: 2026-06-06.

## Current interpretation boundary

- Repository-level mainline now targets complex-terrain flux correction and state classification rather than a single CO2-event explanation.
- `EA_flux_results.csv` remains the main covariance-style EA result set based on `w'`.
- storage is now the first-priority correction branch.
- The new raw-`w` transport branch is kept as a separate diagnostic path.
- The empirical tilt-correction branch is retained only as a diagnostic attempt and is not the current interpretation basis.
- FL remains a cut-plane / cross-section evidence source, not a third mean-flux station.
- CVT/MT fixed-tower raw `w` does not need to be converted to fixed-tower `F_anom` before the current CO2-event synthesis. That branch is optional and only needed if fixed towers and FL must be compared under the same anomaly-transport reference.
- The CO2 secondary-peak synthesis is retained as a reproduction / support branch for the broader flux-correction framework.

## Stable numerical results

### EA / EC
- Main EA result set size: `1152` rows.
- Sites: `MT`, `CVT`, `FL`.
- Scalars: `co2`, `h2o`.
- `F_EA_general` and `F_EC_cov` are essentially identical; the difference is at floating-point error scale.

### CO2 air-mass structure
- Daytime `09:00-15:00` mean values across all sites:
  - `c_up ≈ 432.10`
  - `c_mean ≈ 432.42`
  - `c_down ≈ 432.65`
  - `c_up - c_down ≈ -0.55`
  - net CO2 flux `≈ -0.168`
- Nighttime `00:00-06:00` mean values across all sites:
  - `c_up - c_mean ≈ +0.052`
  - `c_down - c_mean ≈ -0.070`
  - `c_up - c_down ≈ +0.122`
  - net CO2 flux `≈ +0.015`
- Daytime site-level `c_up - c_down`:
  - `CVT ≈ -0.609 ppm`
  - `FL ≈ -0.490 ppm`
  - `MT ≈ -0.504 ppm`

### Raw `w` transport
- Main raw-`w` output size: `4032` rows.
- Windows: `5 min` and `30 min`.
- `F_total_raw_window` is very close to `F_mean_window`.
- `F_turb_window` is about three to four orders of magnitude smaller than the mean-flow term.
- 30 min site-average total transport:
  - `CVT ≈ -24.34`
  - `FL ≈ +31.91`
  - `MT ≈ +74.11`

### Rotation sensitivity
- `com_rotation` contains a 4-method comparison: `none`, `dr`, `pf`, `spf`.
- The 4-method merged result file has `20528` rows.
- Core finding: rotation affects `w_mean` much more strongly than `sigma_w`.
- `Tau` is highly sensitive to rotation choice.
- `co2_flux`, `H`, and `LE` also show meaningful method sensitivity.
- `u_star` is comparatively more stable, but not invariant.

### FL quality-mass-balance work
- Four-day mass-balance runs:
  - total entering runs: `188`
  - `single_sign_w` segments: none
  - `extreme_lambda` segments: `3` in the first version
- Teacher-style 1 min reproduction:
  - total runs: `186`
  - `single_sign` segments: `18`
  - `extreme_lambda` segments: `21`

### FL moving-transect anomaly transport
- Main feasibility branch: `D:\00 博士阶段\博一\05 Project\com_mass_balance`.
- Pass-level table: `193` moving transect passes.
- Lightweight high-frequency matched table: `3,381,493` rows.
- Position-time diagnostic table: `4751` rows.
- Position bins: `25` bins at `10 m` resolution.
- Current quality flags:
  - `low_n = 0`
  - `low_updown = 0`
  - `single_sign = 0`
  - `lambda_extreme = 76`
  - `air_imbalance = 174`
- Current profile-stability result:
  - `all_pass` vs `non_lambda_extreme` median profile correlation: `0.8209436`
  - `all_pass` vs `non_air_imbalance` median profile correlation: `0.2275509`
- Current interpretation: use `non_lambda_extreme` as the primary robustness group; keep `non_air_imbalance` as a sensitivity / warning group because it is stricter and changes the profile strongly.

## Supporting event synthesis

The 2026-06-04 synthesis organizes the CO2 secondary-peak problem as competing hypotheses rather than a single fixed explanation. After the 2026-06-06 mainline reset, this branch is kept as support evidence for when storage, advection, ventilation, and local circulation may disrupt EC interpretation.

### Candidate mechanisms
- H1: night storage release plus sunrise profile / boundary-layer transition.
- H2: wind shift or wind-speed increase imports an external high-CO2 air mass.
- H3: cross-valley local secondary circulation redistributes CO2.
- H4: post-peak decline is mainly ecosystem uptake plus vertical mixing dilution.
- H5: post-peak decline is mainly ventilation or horizontal advection away from the control volume.
- H6: turbulence or thermal variables directly trigger the secondary peak.
- H7: raw-`w` vertical structure mainly reflects coordinate / streamline projection risk.
- H8: combined mechanism.

### Current synthesis status
- H1 is a foundation candidate because `profile switch` and `pre-min` are stable leading signals.
- H2 and H3 are strong candidates but need event-level wind-sector and FL spatial-pattern labels.
- H4 and H5 should be separated as competing explanations for post-peak CO2 decline.
- H6 is currently downgraded to a background or modulating process because turbulence and thermal extrema are not stable pre-peak triggers.
- H7 is a required method-risk check whenever raw `w_mean` or FL vertical motion is interpreted physically.
- H8 should wait until H1-H5 are converted into event-level labels.

## What this supports

These results are enough to support:
- a state-oriented complex-terrain flux-correction framework
- separation of baseline EC interpretation, storage correction, and advection / circulation risk
- separation of air-mass transport and concentration-anomaly interpretation
- continued use of 30 min results for mainline interpretation
- 5 min results for sunrise / sunset / short-event inspection
- method-boundary discussion for rotation, PF, and raw-`w` diagnostics
- event-level mechanism ranking as a support branch for CO2 secondary-peak source and post-peak decline pathways

## What still needs caution

- Do not read raw `wc` as a standard ecosystem CO2 flux without context.
- Do not use the tilt-correction branch as the current mainline interpretation.
- Do not treat FL as a third mean-flux station.
- Do not collapse raw-`w`, covariance flux, and concentration-anomaly structure into one quantity.
- Do not call the secondary peak a storage-release, advection-input, or local-circulation event before the event-level labels connect timing, wind sector, FL spatial pattern, fixed-tower phase, and method risk.

## Next compact outputs

- `complex_terrain_flux_state_framework.md`: state definitions, diagnostics, correction logic, and method-risk notes.
- `ec_state_classification_schema.csv`: state labels such as EC-trustworthy, storage-dominant, external-input, ventilation-removal, cross-valley-redistribution, and high-method-risk.
- `storage_correction_priority_table.csv`: site / period / condition matrix for where local-column storage should be computed first.
- Supporting branch outputs may still include `CO2_event_lead_lag_table.csv`, `FL_event_spatial_pattern_labels.csv`, and `CO2_event_mechanism_ranking.csv`.

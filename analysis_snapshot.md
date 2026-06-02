# Analysis Snapshot

This file collects the current stable results that are most useful for downstream analysis and for model-assisted reading of the repository.

## Current interpretation boundary

- `EA_flux_results.csv` remains the main covariance-style EA result set based on `w'`.
- The new raw-`w` transport branch is kept as a separate diagnostic path.
- The empirical tilt-correction branch is retained only as a diagnostic attempt and is not the current interpretation basis.
- FL remains a cut-plane / cross-section evidence source, not a third mean-flux station.

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

## What this supports

These results are enough to support:
- separation of air-mass transport and concentration-anomaly interpretation
- continued use of 30 min results for mainline interpretation
- 5 min results for sunrise / sunset / short-event inspection
- method-boundary discussion for rotation, PF, and raw-`w` diagnostics

## What still needs caution

- Do not read raw `wc` as a standard ecosystem CO2 flux without context.
- Do not use the tilt-correction branch as the current mainline interpretation.
- Do not treat FL as a third mean-flux station.
- Do not collapse raw-`w`, covariance flux, and concentration-anomaly structure into one quantity.

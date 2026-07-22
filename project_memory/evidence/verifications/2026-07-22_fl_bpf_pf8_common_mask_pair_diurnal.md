# 2026-07-22 FL BPF PF8 / no-rotation common-mask paired diurnal summary

## Status and scope

- Status remains **provisional**. The run used exactly `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_parameters_for_flux.csv` (SHA256 `bc1204e19adb6eafdfb8e8dd64536be60a4871b1ecb119818bd281459027eb09`), not an earlier default table.
- The paired high-frequency product contains all 5,177 retained physical passes. BPF is calculable for 4,662 passes and failed rows are explicit: `no_diag_sonic_zero=428`, `no_raw_file=65`, and `no_samples_in_pass=22`.
- Every retained BPF pass uses the same BPF-valid high-frequency samples for `no_rotation_common`; per-pass `n_bpf_valid == n_common_valid`. The paired total is 79,430,717 high-frequency samples. `0_245_m` and `0_230_m` remain separate, and forward/backward passes are retained separately as well as pooled only for display.
- This is a vertical air-motion / coordinate-method diagnostic. It is not a CO2 flux, a vertical-advection estimate, or evidence of ecosystem exchange.

## Verified computation and outputs

- BPF used pointwise running-record position and signed cart-speed interpolation, horizontal platform-motion correction, the matched 8-bin PF8 coefficients, and `w_bpf = Uz_shared - (a + b * Ueast_corrected + c * Unorth_corrected)` without a pass `w_mean` subtraction. `Uz_shared` is the common QC/despiked vertical series used for both methods.
- All 22 monthly outputs passed UID, common-sample-count, sign, and closure checks. The maximum absolute closure error for either method is `2.27373675443232e-13 m`.
- The daily cycle groups only `bpf_qc_status=ok` / `no_rotation_common_qc_status=ok` passes by Asia/Shanghai half-hour, track scope, and direction. The center is the pass-level median and the band is the 25th--75th percentile; the output also retains pass and date counts.
- Primary paired table: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_pair_pass_air_accumulation_all.csv`.
- Diurnal tables: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_pair_diurnal_30min.csv` and `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_pair_diurnal_BPF_minus_no_rotation_common_30min.csv`.
- Figures: `E:\Dataset_Level1\Flares\Eddy Accumulation\figures\BPF_0_245_PF8_2ensemble_pair_diurnal_qnet_comparison.png` and `E:\Dataset_Level1\Flares\Eddy Accumulation\figures\BPF_0_245_PF8_2ensemble_pair_diurnal_qnet_difference.png`.
- Reproducible runners: `D:\00 博士阶段\99 Project\06 EA\scripts\run_fl_bpf_pf8_pair_air_accumulation.R` and `D:\00 博士阶段\99 Project\06 EA\scripts\summarise_fl_bpf_pf8_pair_diurnal.R`; the latter passed `--self-check` after output generation.

## Observed pattern and boundary

- In the pooled forward/backward comparison, the median BPF-minus-common-no-rotation net vertical-motion difference is most negative at `13:00` for `0_245_m` (`-0.1689486431 m s^-1`) and at `14:00` for `0_230_m` (`-0.1928108660 m s^-1`). The corresponding largest positive medians occur at `06:00` (`0.1309882104 m s^-1`) and `02:30` (`0.1667898762 m s^-1`).
- These are observed coordinate-method differences on matched samples. They support a time-of-day-sensitive rotation effect, but do not identify the physical cause or justify a CO2 transport/advection claim.
- The missing training/raw-date coverage exception remains recorded; therefore the paired product must not be promoted beyond provisional solely because its numerical closures pass.

## Next action

- Preserve this paired table as the only valid BPF/no-rotation comparison input. Any meteorological, source-area, or CO2 interpretation must be added as a separately scoped analysis and must retain the provisional coverage boundary.

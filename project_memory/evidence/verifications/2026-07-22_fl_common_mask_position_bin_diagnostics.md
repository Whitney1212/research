# 2026-07-22 FL BPF/no-rotation common-mask position-bin diagnostics

## Status and scope

- Status: **provisional diagnostic**. This is a downstream diagnostic of the released 0–245 m PF8 paired common-mask product; it does not change the BPF release status or create an ecosystem CO2-flux product.
- Scope: `0_245_m` only; `batch_b_complete` / `0_230_m` is excluded. Forward and backward passes remain traceable in the tables but are pooled in the position figures.
- Parent path: [[../../runtime/research_paths/W1-P02_fl_ec_delivery|W1-P02]].

## Verified inputs and common sample rule

- The paired source is `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_pair_pass_air_accumulation_all.csv`.
- There are 4,112 physical 0–245 m passes and 3,597 paired common-valid passes. Each retained pass uses the identical BPF-valid high-frequency samples for BPF and no-rotation.
- BPF uses `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_parameters_for_flux.csv` (SHA256 `bc1204e19adb6eafdfb8e8dd64536be60a4871b1ecb119818bd281459027eb09`). The eight fixed boundaries are 0, 30.625, 61.25, 91.875, 122.5, 153.125, 183.75, 214.375, and 245 m.

## New base results

- The 10 m product has 25 position bins (the final bin is 240–245 m), 176,312 method-bin rows, and 88,156 rows for each coordinate method.
- The fixed-BPF product has 8 position bins, 56,666 method-bin rows, and 28,333 rows for each coordinate method.
- Each pass-bin-method row contains `Q_*`, `q_up/q_down/q_net/q_gross`, `I_A`, `f_up/f_down/f_zero`, conditional signed-speed means, common-sample counts, CO2 mean/anomaly, EC covariance diagnostic, and EA total/anomaly transport diagnostic.
- All pass-bin-method keys are unique. Time fractions close to one with a maximum absolute residual of `1.1102230246251565e-15`.
- CO2-based quantities are unavailable in 44 method-bin rows for the 10 m table and 16 method-bin rows for the PF8 table because those bins have insufficient finite CO2 samples; their air-motion diagnostics remain present.

## CO2 reference and interpretation boundary

- The concentration reference is the mean CO2 of all finite, common-valid high-frequency samples within the same pass: `c_ref_pass = mean(CO2_pass, common mask)`.
- Therefore `co2_anom_mean_ppm = mean(CO2_bin) - c_ref_pass`; it is not a full-period mean, fixed-tower background, or external background concentration.
- `F_EC_cov_ppm_m_s = cov(w, CO2)` and `F_EA_anom_ppm_m_s = mean(w * (CO2 - c_ref_pass))` are moving-transect diagnostics in `ppm m s^-1`, without density conversion. They are not conventional ecosystem CO2 fluxes.
- In all-pass pooled median profiles, air-motion metrics do not show an obvious continuous position trend. This does not rule out event-, date-, or individual-pass spatial structure.

## Deliverables

- Tables: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_no_rotation_common_pass_bin_10m.csv`; `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_no_rotation_common_pass_bin_BPF8.csv`.
- Plot summaries: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_no_rotation_common_bin_10m_visual_summary.csv`; `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_no_rotation_common_bpf_8bin_visual_summary.csv`.
- Figures: `E:\Dataset_Level1\Flares\Eddy Accumulation\figures\FL_paired_position_bin_10m_air_motion.png`; `FL_paired_position_bin_10m_co2_anomaly.png`; `FL_paired_position_bin_10m_ec_ea_transport.png`; `FL_paired_position_bpf_8bin_air_motion.png`; `FL_paired_position_bpf_8bin_co2_anomaly.png`; `FL_paired_position_bpf_8bin_ec_ea_transport.png`.
- Reproducible scripts: `D:\00 博士阶段\99 Project\06 EA\scripts\build_fl_bpf_no_rotation_pass_pair_0_245.R`; `build_fl_bpf_no_rotation_position_bin_diagnostics.R`; `plot_fl_bpf_no_rotation_position_bin_diagnostics.R`.

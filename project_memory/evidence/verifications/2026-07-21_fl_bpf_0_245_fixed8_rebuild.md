# 2026-07-21 FL BPF 0–245 m fixed-8-bin rebuild

## Scope and decision

- Recomputed FL BPF with the existing PF8 main processing chain, fixed full-track bounds `0–245 m`, and exact eight-bin boundaries `0, 30.625, 61.25, 91.875, 122.5, 153.125, 183.75, 214.375, 245`.
- Primary fitting inputs were `main_complete` plus non-duplicate `oldcode_0_245` passes. `main_complete` took priority; 10 overlapping oldcode passes were excluded. `batch_b_complete` was not used in the primary fit because its track ends at 230 m.
- PF8 preprocessing ran separately by `source_group`; the final two-pass ensemble construction retained the `source_group` boundary. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_pass_inventory.csv`; `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_duplicate_pass_audit.csv`; `D:\00 博士阶段\99 Project\06 EA\scripts\run_fl_bpf_0_245_8bin.R`]

## Verified result

- The final PF2 parameter table has exactly 8 rows with `fit_ok=TRUE` for all bins; `n_points=1714–1732` and both directions are represented in every bin (`n_fw=n_bw=1714–1732`). Bins 7 and 8 have nonzero input. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_parameters_for_flux.csv`]
- All release checks passed: fixed boundaries, 8/8 fits, finite coefficients, `n_points >= 8`, forward/backward coverage, bin 7/8 input, pass de-duplication, no cross-source ensemble, and non-worsening residual criteria. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_release_validation.csv`]
- Per-bin fitted residual RMSE is lower than the pre-rotation RMSE; for example, bin 1 changed from `0.2664692` to `0.1804545 m s^-1`, and bin 8 from `0.2792924` to `0.2227400 m s^-1`. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_parameters_for_flux.csv`]

## Coverage boundary and status

- Raw TOA5 files were unavailable for `main_complete` on `2023_04_17`, `2023_04_18`, `2023_06_18`, and `2025_04_04`; the first two dates were also unavailable for `oldcode_0_245`. The user explicitly authorized proceeding while retaining these omissions in the coverage audit. [verified: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_raw_coverage_audit.csv`]
- Therefore the fitted parameter table is **provisional** despite passing the numerical 8/8 release checks. It must not replace `E:\Dataset_Level1\Flares\BPF\BPF_default_parameters_for_flux.csv` until the missing raw-date coverage is resolved or the exception is formally accepted for production use. [inference: numerical validation passes, but raw-date coverage is incomplete]

## Deliverables

- Runner: `D:\00 博士阶段\99 Project\06 EA\scripts\run_fl_bpf_0_245_8bin.R`.
- Combined pass-bin data: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_all_pass_bin_means.csv`.
- PF2 parameters: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_parameters_for_flux.csv`.
- Fit detail: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_fit_validation.csv`.
- Release and coverage audits: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_release_validation.csv`; `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_raw_coverage_audit.csv`.
- Execution log: `E:\Dataset_Level1\Flares\Eddy Accumulation\logs\BPF_0_245_full_run_stderr.log`.

## Standard promotion decision

- On 2026-07-21, the user approved this 0–245 m fixed-8-bin PF8 two-pass ensemble table as the FL BPF standard. `E:\Dataset_Level1\Flares\BPF\BPF_default_parameters_for_flux.csv` now contains this table; the superseded default is retained as `E:\Dataset_Level1\Flares\BPF\BPF_default_parameters_for_flux_pre_0_245_8bin_20260709.csv`. [verified: both files and SHA256 recorded during promotion]
- The standard package also contains the immutable runner copy, release validation, raw-date coverage audit, and `BPF_0_245_PF8_2ensemble_STANDARD.md`. The raw-date omissions remain an explicit accepted coverage exception rather than an unrecorded data loss. [verified: `E:\Dataset_Level1\Flares\BPF`]

# 2026-07-22 FL 0–245 m paired daily cycles and TOA5 local-time entry standard

## Scope and paired input

- The current FL daily-cycle product uses only the `0_245_m` pass track. Forward and backward passes are pooled for calculation and display; they are not plotted as separate groups.
- The paired pass table contains `4,112` retained `0_245_m` passes. `3,597` are jointly valid for BPF and no-rotation on the identical BPF-common high-frequency sample mask (`87.48%`); both method status fields are `ok` for exactly these passes.
- Among the jointly valid passes, `fw = 1,799` and `bw = 1,798`; valid coverage comprises `146` local dates (`fw` on `142`, `bw` on `146`). All 48 local half-hour bins are represented. Bin counts range from `52` to `94` (median `75.5`), so late morning/afternoon sampling is somewhat denser but no half-hour is absent.
- This remains a vertical air-motion / coordinate-method diagnostic, not a CO2 flux, vertical-advection estimate, or ecosystem-exchange result.

## Computation and daily-cycle convention

- Per pass, both methods retain `Q_up/Q_down/Q_net/Q_gross`, their duration-normalized `q_*` counterparts, `I_A`, upward/downward duration fractions, and conditional upward/downward speeds. `Q_down` and `q_down` are stored positive; only plotted downward curves are negated. The identity `q_up = f_up x mean(w | w > 0)` and its downward counterpart are checked before aggregation.
- The daily cycle first takes the median of multiple passes from the same local date and half-hour, then takes the median and 25th–75th percentiles across dates. Every output row retains effective date and pass counts.
- The primary paired calculation table is `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_no_rotation_common_pass_pair_0_245m.csv`. The wind daily-cycle table is `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_PF8_2ensemble_no_rotation_common_diurnal_30min_daily_median.csv`.
- The wind figures are `E:\Dataset_Level1\Flares\Eddy Accumulation\figures\BPF_0_245_pass_pair_diurnal_q_up_q_down.png`, `BPF_0_245_pass_pair_diurnal_q_net_I_A.png`, `BPF_0_245_pass_pair_diurnal_q_gross.png`, and `BPF_0_245_pass_pair_diurnal_duration_intensity.png`.

## CO2 concentration diagnostic

- CO2 is calculated as the within-pass mean of finite `CO2` samples with `diag_irga == 0`, restricted to the same BPF-common mask; it is not conditioned on the sign of vertical velocity. The valid product includes all `3,597` paired passes and `62,331,899` high-frequency CO2 samples.
- The same two-stage daily aggregation is applied to pass-mean concentration. Output: `E:\Dataset_Level1\Flares\Eddy Accumulation\tables\BPF_0_245_common_mask_co2_diurnal_30min_daily_median.csv`; figure: `E:\Dataset_Level1\Flares\Eddy Accumulation\figures\BPF_0_245_common_mask_co2_diurnal.png`.
- The time-aligned three-facet figure puts BPF vertical motion, no-rotation vertical motion, and CO2 concentration on the same `Asia/Shanghai` half-hour axis. Its black curve is `q_net = q_up - q_down`; it does not imply CO2 transport. Output: `E:\Dataset_Level1\Flares\Eddy Accumulation\figures\BPF_0_245_paired_wind_q_up_q_down_and_co2_diurnal.png`.

## Timestamp safeguard and reproducibility

- Pass timestamps must be read as character before parsing. A prior phase error arose because automatic CSV typing assigned an unzoned local timestamp to UTC, then formatting it as Shanghai time shifted the daily cycle by eight hours. The corrected check maps `2023-04-17 12:52:28.500` to local `12:52`.
- All three sites now use the project TOA5 entry contract: keep raw TOA5 timestamps as character, explicitly parse them as `Asia/Shanghai` local wall-clock time, and only then normalize fields/QC. FL uses `read_toa5_wind()` / `parse_toa5_time()`; MT/CVT retain their established `ecpreproc::read_toa5(..., tz = cfg$tz)` route. This record changes no production computation.
- Reproducible scripts: `D:\00 博士阶段\99 Project\06 EA\scripts\build_fl_bpf_no_rotation_pass_pair_0_245.R`, `summarise_fl_pass_pair_diurnal_0_245.R`, `summarise_fl_paired_co2_diurnal_0_245.R`, `plot_fl_paired_wind_co2_diurnal_0_245.R`, and `lib_fl_pass_core.R`. The two daily-summary self-checks passed after regeneration.

#!/usr/bin/env python
"""Build 2025 morning-peak foundation tables from Level0 AP and CVT MET files.

Outputs:
- fixed_tower_ap_2025_30min.csv: MT/CVT AP CO2 means at 30 min windows.
- fixed_tower_ap_2025_daily_qc.csv: daily AP aggregation diagnostics.
- cvt_sw_sunrise_2025.csv: CVT shortwave sunrise proxy from SW_in_Avg.
"""

from __future__ import annotations

import argparse
import csv
import math
from collections import defaultdict
from dataclasses import dataclass, field
from datetime import date, datetime, time
from pathlib import Path


DEFAULT_LEVEL0 = Path("E:/Dataset_Level0")
DEFAULT_OUTPUT_DIR = Path("E:/Dataset_Level1/MorningPeak/W2_2025_foundation")
CO2_MIN = 200.0
CO2_MAX = 1200.0
SUNRISE_SW_THRESHOLD = 20.0


@dataclass
class APAccumulator:
    n_total: int = 0
    n_diag0: int = 0
    n_valid: int = 0
    co2_sum: float = 0.0
    co2_sumsq: float = 0.0
    valves: set[int] = field(default_factory=set)

    def add(self, co2: float | None, valve: int | None, diag_ok: bool):
        self.n_total += 1
        if diag_ok:
            self.n_diag0 += 1
        if co2 is None or not diag_ok or not (CO2_MIN <= co2 <= CO2_MAX):
            return
        self.n_valid += 1
        self.co2_sum += co2
        self.co2_sumsq += co2 * co2
        if valve is not None:
            self.valves.add(valve)

    def row_values(self):
        if self.n_valid:
            mean = self.co2_sum / self.n_valid
            variance = max(self.co2_sumsq / self.n_valid - mean * mean, 0.0)
            sd = math.sqrt(variance)
        else:
            mean = None
            sd = None
        return mean, sd, len(self.valves), ",".join(str(v) for v in sorted(self.valves))


@dataclass
class MeanAccumulator:
    n: int = 0
    value_sum: float = 0.0

    def add(self, value: float | None):
        if value is None or not math.isfinite(value):
            return
        self.n += 1
        self.value_sum += value

    @property
    def mean(self):
        return self.value_sum / self.n if self.n else None


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build 2025 morning peak foundation tables.")
    parser.add_argument("--level0-root", type=Path, default=DEFAULT_LEVEL0)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--year", type=int, default=2025)
    parser.add_argument("--sw-threshold", type=float, default=SUNRISE_SW_THRESHOLD)
    return parser.parse_args()


def parse_float(value) -> float | None:
    if value is None:
        return None
    text = str(value).strip()
    if not text or text.upper() in {"NAN", "NA", "NULL"}:
        return None
    try:
        value = float(text)
    except ValueError:
        return None
    return value if math.isfinite(value) else None


def parse_int(value) -> int | None:
    number = parse_float(value)
    if number is None:
        return None
    return int(number)


def parse_timestamp(value: str) -> datetime | None:
    value = value.strip().strip('"')
    try:
        return datetime.strptime(value, "%Y-%m-%d %H:%M:%S")
    except ValueError:
        return None


def floor_30min(ts: datetime) -> datetime:
    minute = 0 if ts.minute < 30 else 30
    return ts.replace(minute=minute, second=0, microsecond=0)


def read_toa5(path: Path):
    with path.open("r", encoding="utf-8", errors="replace", newline="") as handle:
        reader = csv.reader(handle)
        try:
            next(reader)
            header = next(reader)
            next(reader)
            next(reader)
        except StopIteration:
            return
        index = {name: i for i, name in enumerate(header)}
        for row in reader:
            if len(row) < len(header):
                continue
            yield index, row


def find_files(root: Path, site: str, kind: str, year: int):
    base = root / site / kind
    if not base.exists():
        raise FileNotFoundError(f"Missing directory: {base}")
    if kind == "AP":
        pattern = f"*SiteAvg_{year}_*.dat"
    elif kind == "MET":
        pattern = f"*OneMin_{year}_*.dat"
    else:
        pattern = f"*{year}*.dat"
    return sorted(base.rglob(pattern))


def build_ap_30min(level0_root: Path, year: int):
    accum: dict[tuple[str, datetime], APAccumulator] = defaultdict(APAccumulator)
    file_counts = {}
    for site in ["CVT", "MT"]:
        files = find_files(level0_root, site, "AP", year)
        file_counts[site] = len(files)
        for path in files:
            for index, row in read_toa5(path):
                ts = parse_timestamp(row[index["TIMESTAMP"]])
                if ts is None or ts.year != year:
                    continue
                co2 = parse_float(row[index["CO2_Avg"]])
                valve = parse_int(row[index["valve_number"]])
                diag = parse_int(row[index["diag_AP200_Avg"]])
                diag_ok = diag == 0
                accum[(site, floor_30min(ts))].add(co2, valve, diag_ok)

    rows = []
    for (site, window_start), acc in sorted(accum.items(), key=lambda x: (x[0][0], x[0][1])):
        mean, sd, n_valves, valves = acc.row_values()
        rows.append({
            "site": site,
            "window_start": window_start.strftime("%Y-%m-%d %H:%M:%S"),
            "date": window_start.date().isoformat(),
            "hour": f"{window_start.hour + window_start.minute / 60:.1f}",
            "co2_mean": "" if mean is None else f"{mean:.6f}",
            "co2_sd": "" if sd is None else f"{sd:.6f}",
            "n_total": acc.n_total,
            "n_diag0": acc.n_diag0,
            "n_valid": acc.n_valid,
            "n_valves": n_valves,
            "valves": valves,
        })
    return rows, file_counts


def build_ap_daily_qc(ap_rows, year: int):
    grouped = defaultdict(lambda: {
        "windows_total": 0,
        "windows_valid": 0,
        "morning_windows_valid": 0,
        "valid_obs": 0,
    })
    for row in ap_rows:
        key = (row["site"], row["date"])
        group = grouped[key]
        group["windows_total"] += 1
        if row["n_valid"] and int(row["n_valid"]) > 0:
            group["windows_valid"] += 1
            group["valid_obs"] += int(row["n_valid"])
            hour = float(row["hour"])
            if 4.0 <= hour <= 12.0:
                group["morning_windows_valid"] += 1

    rows = []
    day = date(year, 1, 1)
    all_days = []
    while day < date(year + 1, 1, 1):
        all_days.append(day.isoformat())
        day = date.fromordinal(day.toordinal() + 1)

    for site in ["CVT", "MT"]:
        for day in all_days:
            values = grouped.get((site, day), {
                "windows_total": 0,
                "windows_valid": 0,
                "morning_windows_valid": 0,
                "valid_obs": 0,
            })
            if values["windows_valid"] >= 48:
                coverage_status = "full_day"
            elif values["windows_valid"] > 0:
                coverage_status = "partial_day"
            else:
                coverage_status = "no_ap_dat_rows"
            rows.append({
                "site": site,
                "date": day,
                **values,
                "coverage_status": coverage_status,
            })
    return rows


def build_cvt_sunrise(level0_root: Path, year: int, threshold: float):
    window_accum: dict[tuple[date, datetime], MeanAccumulator] = defaultdict(MeanAccumulator)
    files = find_files(level0_root, "CVT", "MET", year)
    sw_field_counts = defaultdict(int)
    for path in files:
        for index, row in read_toa5(path):
            sw_col = "SW_in_Avg" if "SW_in_Avg" in index else ("SW_in" if "SW_in" in index else None)
            if sw_col is None:
                continue
            ts = parse_timestamp(row[index["TIMESTAMP"]])
            if ts is None or ts.year != year:
                continue
            sw_in = parse_float(row[index[sw_col]])
            window = floor_30min(ts)
            window_accum[(ts.date(), window)].add(sw_in)
            sw_field_counts[sw_col] += 1

    by_day = defaultdict(list)
    for (day, window), acc in window_accum.items():
        by_day[day].append((window, acc.mean, acc.n))

    rows = []
    day = date(year, 1, 1)
    end = date(year + 1, 1, 1)
    while day < end:
        windows = sorted(by_day.get(day, []))
        sunrise = ""
        max_sw = ""
        first_light_sw = ""
        if windows:
            means = [x[1] for x in windows if x[1] is not None]
            if means:
                max_sw = f"{max(means):.6f}"
            for window, mean, _n in windows:
                if mean is not None and mean >= threshold:
                    sunrise = window.strftime("%Y-%m-%d %H:%M:%S")
                    first_light_sw = f"{mean:.6f}"
                    break
        rows.append({
            "date": day.isoformat(),
            "sunrise_ref_sw": sunrise,
            "threshold_w_m2": threshold,
            "first_light_sw_in": first_light_sw,
            "max_sw_in": max_sw,
            "n_30min_windows": len(windows),
        })
        day = date.fromordinal(day.toordinal() + 1)
    return rows, len(files), dict(sw_field_counts)


def write_csv(path: Path, rows: list[dict]):
    path.parent.mkdir(parents=True, exist_ok=True)
    if not rows:
        raise ValueError(f"No rows to write: {path}")
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def write_notes(path: Path, args, ap_file_counts, met_file_count, sw_field_counts, ap_rows, daily_rows, sunrise_rows):
    valid_ap_windows = sum(1 for row in ap_rows if row["n_valid"] and int(row["n_valid"]) > 0)
    missing_sunrise = sum(1 for row in sunrise_rows if not row["sunrise_ref_sw"])
    with path.open("w", encoding="utf-8") as handle:
        handle.write("Morning peak 2025 foundation build\n")
        handle.write(f"Level0 root: {args.level0_root}\n")
        handle.write(f"Output directory: {args.output_dir}\n")
        handle.write(f"Year: {args.year}\n")
        handle.write("\nInput files:\n")
        handle.write(f"- CVT AP files: {ap_file_counts.get('CVT', 0)}\n")
        handle.write(f"- MT AP files: {ap_file_counts.get('MT', 0)}\n")
        handle.write(f"- CVT MET files: {met_file_count}\n")
        handle.write(f"- CVT MET SW fields used: {sw_field_counts}\n")
        handle.write("\nOutputs:\n")
        handle.write(f"- AP 30min rows: {len(ap_rows)}\n")
        handle.write(f"- AP 30min rows with valid CO2: {valid_ap_windows}\n")
        handle.write(f"- AP daily QC rows: {len(daily_rows)}\n")
        for site in ["CVT", "MT"]:
            site_days = [row for row in daily_rows if row["site"] == site]
            missing = sum(row["coverage_status"] == "no_ap_dat_rows" for row in site_days)
            partial = sum(row["coverage_status"] == "partial_day" for row in site_days)
            handle.write(f"- {site} AP no-data days: {missing}; partial days: {partial}\n")
        handle.write(f"- Sunrise rows: {len(sunrise_rows)}\n")
        handle.write(f"- Sunrise missing days: {missing_sunrise}\n")
        handle.write("\nProcessing notes:\n")
        handle.write("- AP CO2 uses CO2_Avg with diag_AP200_Avg == 0 and a broad 200-1200 ppm range check.\n")
        handle.write("- AP CO2 is averaged by site and 30 min window across valid valve samples.\n")
        handle.write("- Sunrise proxy uses CVT MET SW_in_Avg, or SW_in when the newer field name is used, aggregated to 30 min; first window with SW_in >= threshold is sunrise_ref_sw.\n")
        handle.write("- These are foundation tables only; peak detection rules are not frozen here.\n")


def main():
    args = parse_args()
    ap_rows, ap_file_counts = build_ap_30min(args.level0_root, args.year)
    daily_rows = build_ap_daily_qc(ap_rows, args.year)
    sunrise_rows, met_file_count, sw_field_counts = build_cvt_sunrise(args.level0_root, args.year, args.sw_threshold)

    args.output_dir.mkdir(parents=True, exist_ok=True)
    write_csv(args.output_dir / f"fixed_tower_ap_{args.year}_30min.csv", ap_rows)
    write_csv(args.output_dir / f"fixed_tower_ap_{args.year}_daily_qc.csv", daily_rows)
    write_csv(args.output_dir / f"cvt_sw_sunrise_{args.year}.csv", sunrise_rows)
    write_notes(
        args.output_dir / f"morning_peak_{args.year}_foundation_run_notes.txt",
        args,
        ap_file_counts,
        met_file_count,
        sw_field_counts,
        ap_rows,
        daily_rows,
        sunrise_rows,
    )

    valid_ap_windows = sum(1 for row in ap_rows if row["n_valid"] and int(row["n_valid"]) > 0)
    missing_sunrise = sum(1 for row in sunrise_rows if not row["sunrise_ref_sw"])
    print(f"Wrote outputs to {args.output_dir}")
    print(f"AP 30min rows: {len(ap_rows)}")
    print(f"AP valid 30min rows: {valid_ap_windows}")
    print(f"Sunrise missing days: {missing_sunrise}")


if __name__ == "__main__":
    main()

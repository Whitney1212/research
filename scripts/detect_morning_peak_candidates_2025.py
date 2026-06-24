#!/usr/bin/env python
"""Create provisional 2025 morning-peak candidate metrics from AP 30 min data.

This script does not freeze the event rule. It produces per-site, per-day
metrics using sunrise-relative windows so the rule can be inspected before it
is formalized.
"""

from __future__ import annotations

import argparse
import csv
from collections import defaultdict
from datetime import datetime
from pathlib import Path


DEFAULT_INPUT_DIR = Path("E:/Dataset_Level1/MorningPeak/W2_2025_foundation")
DEFAULT_OUTPUT_DIR = Path("E:/Dataset_Level1/MorningPeak/W2_2025_candidates")


def parse_args():
    parser = argparse.ArgumentParser(description="Build provisional morning peak candidates.")
    parser.add_argument("--input-dir", type=Path, default=DEFAULT_INPUT_DIR)
    parser.add_argument("--output-dir", type=Path, default=DEFAULT_OUTPUT_DIR)
    parser.add_argument("--year", type=int, default=2025)
    parser.add_argument("--pre-start-hr", type=float, default=0.0)
    parser.add_argument("--pre-end-hr", type=float, default=2.5)
    parser.add_argument("--peak-start-hr", type=float, default=2.5)
    parser.add_argument("--peak-end-hr", type=float, default=4.5)
    parser.add_argument("--post-end-hr", type=float, default=6.5)
    return parser.parse_args()


def read_csv(path: Path):
    with path.open("r", encoding="utf-8-sig", newline="") as handle:
        yield from csv.DictReader(handle)


def parse_time(value: str) -> datetime | None:
    if not value:
        return None
    return datetime.strptime(value, "%Y-%m-%d %H:%M:%S")


def parse_float(value: str) -> float | None:
    if value is None or value == "":
        return None
    return float(value)


def write_csv(path: Path, rows: list[dict]):
    path.parent.mkdir(parents=True, exist_ok=True)
    if not rows:
        raise ValueError(f"No rows to write: {path}")
    with path.open("w", encoding="utf-8-sig", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0].keys()))
        writer.writeheader()
        writer.writerows(rows)


def load_inputs(input_dir: Path, year: int):
    ap_path = input_dir / f"fixed_tower_ap_{year}_30min.csv"
    qc_path = input_dir / f"fixed_tower_ap_{year}_daily_qc.csv"
    sunrise_path = input_dir / f"cvt_sw_sunrise_{year}.csv"

    ap_by_site_date = defaultdict(list)
    for row in read_csv(ap_path):
        co2 = parse_float(row["co2_mean"])
        ts = parse_time(row["window_start"])
        if co2 is None or ts is None:
            continue
        ap_by_site_date[(row["site"], row["date"])].append({
            "time": ts,
            "co2": co2,
            "n_valid": int(row["n_valid"]),
            "n_valves": int(row["n_valves"]),
        })

    qc = {(row["site"], row["date"]): row for row in read_csv(qc_path)}
    sunrise = {row["date"]: row for row in read_csv(sunrise_path)}
    return ap_by_site_date, qc, sunrise


def min_record(records):
    if not records:
        return None
    return min(records, key=lambda x: (x["co2"], x["time"]))


def max_record(records):
    if not records:
        return None
    return max(records, key=lambda x: (x["co2"], -x["time"].timestamp()))


def fmt_time(record):
    return "" if record is None else record["time"].strftime("%Y-%m-%d %H:%M:%S")


def fmt_number(value):
    return "" if value is None else f"{value:.6f}"


def build_candidates(args, ap_by_site_date, qc, sunrise):
    rows = []
    for site in ["CVT", "MT"]:
        site_dates = sorted({date for s, date in qc if s == site})
        for day in site_dates:
            qc_row = qc.get((site, day), {})
            sunrise_time = parse_time(sunrise.get(day, {}).get("sunrise_ref_sw", ""))
            records = sorted(ap_by_site_date.get((site, day), []), key=lambda x: x["time"])

            usable = (
                qc_row.get("coverage_status") == "full_day"
                and sunrise_time is not None
                and len(records) > 0
            )
            pre = []
            peak = []
            post = []
            if usable:
                for record in records:
                    rel_hr = (record["time"] - sunrise_time).total_seconds() / 3600.0
                    if args.pre_start_hr <= rel_hr <= args.pre_end_hr:
                        pre.append(record)
                    if args.peak_start_hr < rel_hr <= args.peak_end_hr:
                        peak.append(record)
                    if args.peak_start_hr < rel_hr <= args.post_end_hr:
                        post.append(record)

            pre_min = min_record(pre)
            peak_max = max_record(peak)
            post_min = min_record([r for r in post if peak_max is not None and r["time"] >= peak_max["time"]])

            amp = None
            decline = None
            decline_rate = None
            if pre_min is not None and peak_max is not None:
                amp = peak_max["co2"] - pre_min["co2"]
            if peak_max is not None and post_min is not None:
                decline = peak_max["co2"] - post_min["co2"]
                hours = (post_min["time"] - peak_max["time"]).total_seconds() / 3600.0
                if hours > 0:
                    decline_rate = decline / hours

            rows.append({
                "site": site,
                "date": day,
                "usable_for_provisional_rule": "TRUE" if usable and pre_min and peak_max else "FALSE",
                "coverage_status": qc_row.get("coverage_status", ""),
                "sunrise_ref_sw": "" if sunrise_time is None else sunrise_time.strftime("%Y-%m-%d %H:%M:%S"),
                "pre_window_hr": f"{args.pre_start_hr:g}-{args.pre_end_hr:g}",
                "peak_window_hr": f"{args.peak_start_hr:g}-{args.peak_end_hr:g}",
                "post_window_hr": f"{args.peak_start_hr:g}-{args.post_end_hr:g}",
                "pre_min_time": fmt_time(pre_min),
                "pre_min_co2": fmt_number(None if pre_min is None else pre_min["co2"]),
                "peak_time": fmt_time(peak_max),
                "peak_co2": fmt_number(None if peak_max is None else peak_max["co2"]),
                "peak_amp_ppm": fmt_number(amp),
                "post_min_time": fmt_time(post_min),
                "post_min_co2": fmt_number(None if post_min is None else post_min["co2"]),
                "post_decline_ppm": fmt_number(decline),
                "post_decline_rate_ppm_h": fmt_number(decline_rate),
                "flag_amp_ge_5ppm": "TRUE" if amp is not None and amp >= 5 else "FALSE",
                "flag_amp_ge_10ppm": "TRUE" if amp is not None and amp >= 10 else "FALSE",
                "n_pre_windows": len(pre),
                "n_peak_windows": len(peak),
                "n_post_windows": len(post),
            })
    return rows


def build_summary(rows):
    summary = []
    for site in ["CVT", "MT"]:
        site_rows = [row for row in rows if row["site"] == site]
        usable = [row for row in site_rows if row["usable_for_provisional_rule"] == "TRUE"]
        ge5 = [row for row in usable if row["flag_amp_ge_5ppm"] == "TRUE"]
        ge10 = [row for row in usable if row["flag_amp_ge_10ppm"] == "TRUE"]
        amps = [float(row["peak_amp_ppm"]) for row in usable if row["peak_amp_ppm"]]
        mean_amp = sum(amps) / len(amps) if amps else None
        summary.append({
            "site": site,
            "total_days": len(site_rows),
            "usable_days": len(usable),
            "amp_ge_5ppm_days": len(ge5),
            "amp_ge_10ppm_days": len(ge10),
            "mean_amp_ppm": "" if mean_amp is None else f"{mean_amp:.6f}",
        })
    return summary


def main():
    args = parse_args()
    ap_by_site_date, qc, sunrise = load_inputs(args.input_dir, args.year)
    rows = build_candidates(args, ap_by_site_date, qc, sunrise)
    summary = build_summary(rows)
    args.output_dir.mkdir(parents=True, exist_ok=True)
    write_csv(args.output_dir / f"morning_peak_candidates_{args.year}_provisional.csv", rows)
    write_csv(args.output_dir / f"morning_peak_candidates_{args.year}_summary.csv", summary)
    with (args.output_dir / f"morning_peak_candidates_{args.year}_run_notes.txt").open("w", encoding="utf-8") as handle:
        handle.write("Provisional morning peak candidate metrics\n")
        handle.write(f"Input directory: {args.input_dir}\n")
        handle.write(f"Output directory: {args.output_dir}\n")
        handle.write(f"Year: {args.year}\n")
        handle.write("This run does not freeze event rules.\n")
        handle.write("Pre-min and peak windows are sunrise-relative and should be inspected before formal use.\n")
    print(f"Wrote outputs to {args.output_dir}")
    for row in summary:
        print(
            f"{row['site']}: usable={row['usable_days']}, "
            f"amp>=5={row['amp_ge_5ppm_days']}, amp>=10={row['amp_ge_10ppm_days']}"
        )


if __name__ == "__main__":
    main()

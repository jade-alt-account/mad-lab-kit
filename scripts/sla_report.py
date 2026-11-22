# sla_report.py: availability, MTTR and SLA compliance from an incident log
import csv
from datetime import datetime

SLA_TARGET = 99.5          # agreed availability, percent
PERIOD_HOURS = 30 * 24     # reporting period: a 30-day month
FMT = "%Y-%m-%d %H:%M"

downtime = {}              # service -> total hours down
incidents = {}             # service -> number of incidents
with open("incidents.csv", newline="") as f:
    for row in csv.DictReader(f):
        start = datetime.strptime(row["start"], FMT)
        end = datetime.strptime(row["end"], FMT)
        hours = (end - start).total_seconds() / 3600
        svc = row["service"]
        downtime[svc] = downtime.get(svc, 0) + hours
        incidents[svc] = incidents.get(svc, 0) + 1

for svc in sorted(downtime):
    avail = 100 * (1 - downtime[svc] / PERIOD_HOURS)
    mttr = downtime[svc] / incidents[svc]
    status = "met" if avail >= SLA_TARGET else "MISSED"
    print(f"{svc:<10} incidents: {incidents[svc]}, MTTR {mttr:.1f} h, "
          f"availability {avail:.2f}% -> SLA {status}")

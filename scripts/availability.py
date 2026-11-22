# availability.py: availability calculations for this module
MINUTES_PER_YEAR = 365 * 24 * 60

def allowed_downtime(percent):
    """Minutes of downtime per year allowed by an availability percentage."""
    return MINUTES_PER_YEAR * (1 - percent / 100)

def availability(mtbf, mttr):
    """Availability of one component from MTBF and MTTR (both in hours)."""
    return mtbf / (mtbf + mttr)

def serial(*parts):
    total = 1.0
    for a in parts:
        total *= a
    return total

def parallel(*parts):
    all_fail = 1.0
    for a in parts:
        all_fail *= (1 - a)
    return 1 - all_fail

for p in (99.0, 99.9, 99.99, 99.999):
    print(f"{p}% allows {allowed_downtime(p):,.1f} minutes of downtime per year")

disk = availability(mtbf=750_000, mttr=8)
print(f"One disk (MTBF 750,000 h, MTTR 8 h): {disk:.6f}")
print(f"Serial 0.99 x 0.99: {serial(0.99, 0.99):.4f}")
print(f"Parallel 0.99 and 0.99: {parallel(0.99, 0.99):.4f}")

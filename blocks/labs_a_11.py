def parallel(*parts):
    all_fail = 1.0
    for a in parts:
        all_fail *= (1 - a)
    return 1 - all_fail

TIERS = {"Tier I": 0.99671, "Tier II": 0.99741,
         "Tier III": 0.99982, "Tier IV": 0.99995}
for name, a in TIERS.items():
    hours = (1 - a) * 8760
    print(f"{name}: {a:.3%}, {hours:.1f} hours down per year")
two = parallel(TIERS["Tier II"], TIERS["Tier II"])
print(f"Two Tier II sites: {two:.5%}, "
      f"{(1 - two) * 8760 * 60:.1f} minutes down per year")

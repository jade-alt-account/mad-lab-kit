HOURS = 24 * 365
before_kwh = 30 * 250 * HOURS / 1000     # 30 servers at 250 W
after_kwh = 3 * 500 * HOURS / 1000       # 3 hosts at 500 W
tariff = 50                              # PKR per kWh (state your own)
saving = before_kwh - after_kwh
print(f"Saving: {saving:,.0f} kWh, PKR {saving * tariff:,.0f} per year")

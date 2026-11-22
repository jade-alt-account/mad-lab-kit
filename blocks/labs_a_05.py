current = serial(0.995, 0.995, 0.99, 0.999)   # web, database, Internet, firewall
print(f"Current design: {current:.4%}, "
      f"{(1 - current) * MINUTES_PER_YEAR / 60:,.1f} hours down per year")

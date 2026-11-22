# pue.py: Power Usage Effectiveness and the cost of overhead power
HOURS_PER_YEAR = 24 * 365

def pue(total_kw, it_kw):
    """Power Usage Effectiveness: total facility power / IT equipment power."""
    return total_kw / it_kw

def overhead_cost(it_kw, pue_value, price_per_kwh):
    """Yearly cost of the power used by everything except the IT equipment."""
    overhead_kw = it_kw * pue_value - it_kw
    return overhead_kw * HOURS_PER_YEAR * price_per_kwh

print(f"PUE: {pue(total_kw=1500, it_kw=1000):.2f}")
cost = overhead_cost(it_kw=1000, pue_value=1.5, price_per_kwh=0.12)
print(f"Yearly overhead cost: ${cost:,.2f}")
cost_pkr = overhead_cost(it_kw=1000, pue_value=1.5, price_per_kwh=50)
print(f"Yearly overhead cost at PKR 50/kWh: PKR {cost_pkr:,.0f}")

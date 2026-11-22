. ~/trial/labs/lib.sh
cd ~ && python3 $S/pue.py | tee /tmp/l4a.out
expect "Lab 4 step 1: PUE 1.50" /tmp/l4a.out 'PUE: 1.50'
expect "Lab 4 step 1: USD cost" /tmp/l4a.out '525,600.00'
expect "Lab 4 step 1: PKR cost" /tmp/l4a.out '219,000,000'
python3 $B/labs_a_11.py | tee /tmp/l4b.out
expect "Lab 4 step 3: Tier I hours" /tmp/l4b.out 'Tier I: 99.671%, 28.8 hours'
expect "Lab 4 step 3: two Tier II sites" /tmp/l4b.out '99.9993.*3.5 minutes'

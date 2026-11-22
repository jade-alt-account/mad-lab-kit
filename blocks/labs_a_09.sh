pkill -f "http.server 8001"
for i in $(seq 15); do date +%T; curl -s -m 1 localhost; sleep 1; done

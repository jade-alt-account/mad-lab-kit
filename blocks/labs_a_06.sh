mkdir -p ~/web1 ~/web2
echo "<h1>Served by web1</h1>" > ~/web1/index.html
echo "<h1>Served by web2</h1>" > ~/web2/index.html
nohup python3 -m http.server 8001 --directory ~/web1 > /dev/null 2>&1 &
nohup python3 -m http.server 8002 --directory ~/web2 > /dev/null 2>&1 &
sleep 1
curl -s localhost:8001; curl -s localhost:8002

mkdir -p ~/web1 ~/web2
echo "<h1>Served by web1</h1>" > ~/web1/index.html
echo "<h1>Served by web2</h1>" > ~/web2/index.html
(cd ~/web1 && nohup python3 -m http.server 8001 > /dev/null 2>&1 &)
(cd ~/web2 && nohup python3 -m http.server 8002 > /dev/null 2>&1 &)
curl -s localhost:8001; curl -s localhost:8002

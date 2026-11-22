sudo mkdir -p /backup
sudo tar --listed-incremental=/backup/etc.snar -czf /backup/etc-full.tar.gz /etc
sudo touch /etc/lab7-change.conf
sudo tar --listed-incremental=/backup/etc.snar -czf /backup/etc-incr1.tar.gz /etc
ls -lh /backup
cd /backup && sudo sha256sum etc-*.tar.gz | sudo tee SHA256SUMS
sudo sha256sum -c SHA256SUMS

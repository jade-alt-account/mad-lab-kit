mkdir -p ~/restore && cd ~/restore
sudo tar --listed-incremental=/dev/null -xzf /backup/etc-full.tar.gz
sudo tar --listed-incremental=/dev/null -xzf /backup/etc-incr1.tar.gz
ls etc/lab7-change.conf && diff etc/hostname /etc/hostname && echo "Restore OK"

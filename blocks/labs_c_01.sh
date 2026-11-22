df -Th                                   # file systems and their types
systemctl list-units --type=service --state=running
ps -eo pid,ni,pri,comm --sort=-pri | head

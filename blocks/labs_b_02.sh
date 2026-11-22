for i in $(seq $(nproc)); do sha256sum /dev/zero & done

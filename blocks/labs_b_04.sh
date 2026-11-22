if [ -d /sys/firmware/efi ]; then echo "Booted with UEFI"
else echo "Booted with legacy BIOS"; fi
mokutil --sb-state 2>/dev/null || echo "Secure Boot state not available"

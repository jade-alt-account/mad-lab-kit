.\VBoxManage.exe list vms
.\VBoxManage.exe list runningvms
.\VBoxManage.exe showvminfo "srv042" --machinereadable |
    Select-String "memory|cpus|VMState"
.\VBoxManage.exe snapshot "srv042" list

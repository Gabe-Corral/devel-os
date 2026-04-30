#!/usr/bin/env bash

# Show used memory similar to htop: used = MemTotal - MemAvailable.
awk '
/^MemTotal:/     { total = $2 }
/^MemAvailable:/  { avail = $2 }
END {
    if (!total || !avail) exit 0

    used = total - avail
    used_g = used / 1024 / 1024

    printf "MEM %.1fG\n", used_g
}
' /proc/meminfo

#!/bin/bash

echo "Server Performance Stats"
echo "--------------------------"

# --- 1. CPU Usage ---
echo "CPU Usage:"
# Menghitung persentase penggunaan CPU secara keseluruhan
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.2f", usage}')
echo "${cpu_usage}%"

echo "---"

# --- 2. Memory Usage (Free vs Used including percentage) ---
echo "Total Memory"
# Total memory terpakai (persentase dan KB)
mem_used_percent=$(free | grep Mem | awk '{memused=$3/$2*100} END {printf "%.2f", memused}')
mem_used_kb=$(free | grep Mem | awk '{print $3}')
echo "Used: ${mem_used_percent}% (${mem_used_kb}K)"

# Total memory bebas (persentase dan KB)
mem_free_percent=$(free | grep Mem | awk '{memfree=$4/$2*100} END {printf "%.2f", memfree}')
mem_free_kb=$(free | grep Mem | awk '{print $4}')
echo "Free: ${mem_free_percent}% (${mem_free_kb}K)"

echo "---"

# --- 3. Total Disk Usage (Free vs Used including percentage) ---
echo "Total Disk Usage"

# Hitung total kapasitas, total terpakai, dan total bebas (dalam KB) dari semua filesystem utama
read total_size total_used total_free <<< $(df -k --exclude-type=tmpfs --exclude-type=devtmpfs | awk 'NR>1 {
    total_size+=$2;
    total_used+=$3;
    total_free+=$4;
} END {
    print total_size, total_used, total_free
}')

if [ -n "$total_size" ] && [ "$total_size" -gt 0 ]; then
    disk_used_percent=$(awk "BEGIN {printf \"%.2f\", $total_used / $total_size * 100}")
    disk_free_percent=$(awk "BEGIN {printf \"%.2f\", $total_free / $total_size * 100}")
    
    echo "Used: ${disk_used_percent}% (${total_used}K)"
    echo "Free: ${disk_free_percent}% (${total_free}K)"
else
    echo "Could not calculate disk usage."
fi

echo "---"

# --- 4. Top 5 processes by CPU usage ---
echo "Top 5 processes by CPU usage (Format: %CPU Command)"
# Mengambil 5 proses teratas dan menampilkan %CPU dan Command
ps aux --sort=-%cpu | head -n 6 | awk 'NR>1 {print $3"% " $11}'

echo "---"

# --- 5. Top 5 processes by memory usage ---
echo "Top 5 processes by memory usage (Format: %MEM Command)"
# Mengambil 5 proses teratas dan menampilkan %MEM dan Command
ps aux --sort=-%mem | head -n 6 | awk 'NR>1 {print $4"% " $11}'

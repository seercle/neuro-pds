import csv
import matplotlib.pyplot as plt
from datetime import datetime

csv_file = "../docker/OUTPUTS/sub001_task002_run001_bold.nii.gz/memory_usage.csv"

timestamps = []
mem_usage = []

with open(csv_file, "r") as file:
    reader = csv.reader(file)
    for row in reader:
        timestamp, mem_in_gib = row
        timestamps.append(datetime.strptime(timestamp, "%Y-%m-%d_%H:%M:%S"))
        mem_usage.append(float(mem_in_gib))

start_time = timestamps[0]
elapsed_time = [(t - start_time).total_seconds() for t in timestamps]

plt.figure(figsize=(10, 6))
plt.plot(elapsed_time, mem_usage, marker="o", linestyle="-")
plt.title("Memory Usage Over Time")
plt.xlabel("Elapsed Time (seconds)")
plt.ylabel("Memory Usage (GiB)")
plt.grid()
plt.show()

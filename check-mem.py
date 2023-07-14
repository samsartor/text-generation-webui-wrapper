#!/usr/bin/env python3

from pathlib import Path
import sys

MINIMUM_MEM = 24
MINIMUM_AVAIL = 1
BYTES_IN_GB = 1024**3 # strictly wrong, but matches system info display

def get_available_bytes():
	meminfo = Path('/proc/meminfo').read_text()
	for line in meminfo.split('\n'):
		name, rest = line.split(':')
		if name == 'MemAvailable':
			return int(rest.strip().split(' ')[0]) * 1024

def get_used_bytes():
	return int(Path('/sys/fs/cgroup/memory.current').read_text())

try:
	used_gb = get_used_bytes() / BYTES_IN_GB
	available_gb = get_available_bytes() / BYTES_IN_GB
except Exception as e:
	print(e, file=sys.stderr, end='')
	exit(60)

if used_gb + available_gb < MINIMUM_MEM:
	print(f'Not enough system memory ({used_gb + available_gb:.2f}GB). Try stopping other services.', file=sys.stderr, end='')
	exit(1)

if used_gb > MINIMUM_MEM and available_gb < MINIMUM_AVAIL:
	print(f'Using too much system memory ({used_gb:.2f}GB). Try a smaller model or lower settings.', file=sys.stderr, end='')
	exit(2)


#!/usr/bin/python3.10

import os

def find_marker(buffer, marker_size):
    for pos in range(marker_size, len(buffer)):
        chars = {}
        for c in buffer[ pos - marker_size : pos ]:
            chars[c] = 1
        if len(chars) == marker_size:
            return pos
    return -1

input = open(os.getenv('ADVENT_INPUT'), "r").read()
print("PART1: %d" % find_marker(input, 4))
print("PART2: %d" % find_marker(input, 14))

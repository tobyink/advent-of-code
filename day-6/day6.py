#!/usr/bin/python3.10

from pprint import pprint

def find_marker(buffer, marker_size):
    for pos in range(marker_size, len(buffer)):
        chars = {}
        for c in buffer[ pos - marker_size : pos ]:
            chars[c] = 1
        if len(chars) == marker_size:
            return pos
    return 0

input = open("input.txt", "r").read()
print("Start of packet:  %d" % (find_marker(input, 4)))
print("Start of message: %d" % (find_marker(input, 14)))


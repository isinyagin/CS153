#!/usr/bin/python

import sys
import os 

def inject_line(line):
    return "\tmove $a0, $2\n\tj printInt"

# Reads file, outputting to stdout, and invoking injection on pattern match
def search_file(filename):
    # Scope tracking
    in_main = False

    # Pull open file
    t_file = open(filename, 'r')
    # Line by line read
    for line in t_file:
        # Conditional inject
        if in_main and line.find("jr\t$31") != -1:
            # Line check for return
            print inject_line(line),

        else:
            if line.find("main:") != -1 :
                # Entering main scope
                in_main = True
            # Stdout
            print line,



if(len(sys.argv) > 1):
    filename = sys.argv[1]
    search_file(filename)
else:
    print "File not found"
    exit(1)
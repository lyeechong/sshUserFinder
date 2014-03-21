#!/lusr/bin/python

CSHOSTS_FILENAME = 'cshosts.dat'

lines = open(CSHOSTS_FILENAME).read().splitlines()

for line in lines:
    print line

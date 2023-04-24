import numpy as np
import sys
import subprocess

infilename=sys.argv[1]


def file_len(fname):
	p = subprocess.Popen(['wc', '-l', fname],
			stdout=subprocess.PIPE, 
			stderr=subprocess.PIPE)
	result, err = p.communicate()
	if p.returncode != 0:
		raise IOError(err)
	return int(result.strip().split()[0])

def col_count(fname):
	f = open(fname, 'r')
	line = f.readline()
	f.close()
	return len(line.split())

def min_max(fname, num_lines, num_columns):
	minimum = 1.0E30
	maximum = 1.0E-30
	minmax = np.zeros((num_columns,2))
	for c in range(num_columns):
		minmax[c,0] = minimum
		minmax[c,1] = maximum

	infile = open(fname, 'r')
	for l in range(num_lines):
		if(((l*100)/num_lines)%5 == 0 and ((l*100)/num_lines) >= 0.0):
			print("Minmax calculation.. [%d of %d] %f complete\n"%(l+1, num_lines, (l*100)/num_lines))	

		line = infile.readline()
		for c in range(num_columns):
			if(float(line.split()[c]) < minmax[c,0]):
				minmax[c,0] = float(line.split()[c])
			if(float(line.split()[c]) > minmax[c,1]):
				minmax[c,1] = float(line.split()[c])
	infile.close()
	return minmax


num_lines = file_len(infilename)
num_columns = col_count(infilename)
minmax = min_max(infilename, num_lines, num_columns)

print("%s: Num lines %d Num columns %d\n"%(infilename, num_lines, num_columns))
outfname = "%s.minmax"%(infilename)
outfile = open(outfname, 'w')

# Write the min
for c in range(num_columns):
	outfile.write("%f "%(minmax[c,0]))
outfile.write("\n")

# Write the max
for c in range(num_columns):
	outfile.write("%f "%(minmax[c,1]))
outfile.write("\n")


dist = 0.0
for c in range(num_columns):
	dist = dist + (minmax[c,0]-minmax[c,1])*(minmax[c,0]-minmax[c,1])

# Write out the max distance possible in this space
outfile.write("%f\n"%(dist))
outfile.close()

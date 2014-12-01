# infile outfile nagents ntargets

# import networkx as nx
import math
import sys;
import re;

# Open Input File for Reading
infile = open(sys.argv[1],'rt');
# Open Output File for Writing
outfile = open(sys.argv[2],'w');

nAgents = int(sys.argv[3]);
nTargets = int(sys.argv[4]);

def cubeIndex2int(i,j,k,J,K):
    return  ((i-1)*J*K) + ((j-1)*K) + k -1;    

def sqIndex2int(i,j,J):
    return ((i-1)*J) + j - 1;    


sOffset = nAgents * nTargets * nTargets;
eOffset = sOffset + (nAgents * nTargets);

strMap = {}
for i in range(1,nAgents + 1):
    for j in range(1,nTargets + 1 ):
        for k in range(1,nTargets + 1):
            print("' Y_" + str(i) + "_" + str(j) + "_" + str(k) + " ' => ' C" + str(cubeIndex2int(i,j,k,nTargets,nTargets)) + " '")
            strMap[" C"+ str(cubeIndex2int(i,j,k,nTargets,nTargets)) + " "] = ' Y_' + str(i) + "_" + str(j) + "_" + str(k) + " ";

for i in range(1,nAgents + 1):
    for j in range(1,nTargets + 1):
	print ("' S_" + str(i) + "_" + str(j) + " ' => ' C" + str(sqIndex2int(i,j,nTargets) + sOffset )+ " '");
        strMap[" C" + str(sqIndex2int(i,j,nTargets) + sOffset )+ " "] = ' S_' + str(i) + "_" + str(j) + " ";
for i in range(1,nAgents + 1):
    for j in range(1,nTargets + 1):
	print ("' E_" + str(i) + "_" + str(j) + " ' => ' C" + str(sqIndex2int(i,j,nTargets) + eOffset )+ " '");
	strMap[" C" + str(sqIndex2int(i,j,nTargets) + eOffset )+ " "] = ' E_' + str(i) + "_" + str(j) + " ";

#print strMap

newLines = [];
for line in infile:
    if re.match('^\s*$',line):
        continue
    for key in strMap.keys():
        p = re.compile(key);
	line = p.sub(strMap[key],line);
    newLines.append(line);

for line in newLines:
    outfile.write(line)
outfile.close();
infile.close();

import yaml, sys
from cfn_tools import load_yaml, dump_yaml
from collections import OrderedDict

sourceName = str(sys.argv[1])
addonName = str(sys.argv[2])
outputName = sourceName
source = open(sourceName, 'r').read()
addon = open(addonName,'r').read()
addonObj = load_yaml(addon)
sourceObj = load_yaml(source)
sourceKeys = sourceObj.keys()
res = sourceObj['Resources']
if( 'TeamAdminPermissionBoundaryPolicy' in res):
    temp = res['TeamAdminPermissionBoundaryPolicy']['Properties']['PolicyDocument']['Statement']
    temp.append(addonObj)
    sourceObj['Resources']['TeamAdminPermissionBoundaryPolicy']['Properties']['PolicyDocument']['Statement']= temp
if( 'TeamWidePermissionBoundaryPolicy' in res):
    temp = res['TeamWidePermissionBoundaryPolicy']['Properties']['PolicyDocument']['Statement']
    temp.append(addonObj)
    sourceObj['Resources']['TeamWidePermissionBoundaryPolicy']['Properties']['PolicyDocument']['Statement']= temp
'''sourceObj.update(addonObj)
sourceObj.move_to_end('Outputs', last=True)
print(sourceObj)'''

output = dump_yaml(sourceObj)
outputFile = open(outputName,"w")
outputFile.write(output)
outputFile.close()

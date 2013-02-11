import fileinput

__TYPEDIC__ = {}
__RULENUM__ = 0
__MINCONFIDENCE__ = 0.5

def parseFile(inputfile,outputfile,typesdic,minconfidence=0.5):
    global __RULENUM__, __MINCONFIDENCE__
    __RULENUM__ = 0
    __MINCONFIDENCE__ = minconfidence
    fout = open(outputfile, "w")
    loadTypeDic(typesdic)
    fout.write("package es.upm.dit.gsi.trainmining;\n\n")
    fout.write("import es.upm.dit.gsi.trainmining.model.Alarm;\n")
    fout.write("import es.upm.dit.gsi.trainmining.model.PossibleEvent;\n")
    fout.write("global java.util.List resultList;\n\n")
    for line in fileinput.input(inputfile):
      fout.write(parseLine(line))
    fout.close()

def parseLine(line):
    global __TYPEDIC__, __RULENUM__, __MINCONFIDENCE__
    if line[1] == '"':
        return ""
    line = line.split('},{')
    LHS = line[0].split(',');
    RHS = line[1].split(',');
    confidence = RHS[1]
    if (float(confidence) < __MINCONFIDENCE__):
        return ""
    antecedents = LHS[1:]
    antecedents[0] = antecedents[0].replace('"<{','')
    consequent = RHS[0]
    consequent = consequent.replace('}>"','')
    ruletext = 'rule "rule{number}"'.format(number=__RULENUM__)
    __RULENUM__+=1
    ruletext += '\n    when \n        Alarm(iid : installationID, alarmCode == "{eventcode}");'.format(eventcode = antecedents.pop(0))
    for ant in antecedents:
        ruletext += '\n        Alarm(installationID == iid, alarmCode == "{eventcode}");'.format(eventcode = ant)
    conseqtype = __TYPEDIC__.get(consequent,"")
    ruletext += '\n    then \n        PossibleEvent p = new PossibleEvent("{eventcode}","{alarmtype}",iid,{confidence});'.format(eventcode = consequent, alarmtype = conseqtype, confidence = confidence)
    ruletext += '\n        resultList.add(p);\nend\n\n'
    return ruletext
    
def loadTypeDic(dictfile):
    global __TYPEDIC__
    dicc = {}
    for line in fileinput.input(dictfile):
        line = line.replace('\n','')
        line = line.replace('\r','')
        line = line.split(",")
        key = line[1].replace('"','')
        value = line[2].replace('"','')
        dicc[key] = value
    __TYPEDIC__ = dicc
  

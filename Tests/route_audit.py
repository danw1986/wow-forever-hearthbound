import re,json,sys,collections
_db=json.load(open(sys.argv[2])); _db=_db.get('Quest',_db)
Q={int(k):v for k,v in _db.items()}
L=open(sys.argv[1],encoding='utf-8').read().splitlines()
steps=[]
for l in L:
    m=re.match(r'\s*\{t="(\w+)"',l)
    if not m: continue
    d={'t':m.group(1)}
    q=re.search(r'\bq=(\d+)',l); d['q']=int(q.group(1)) if q else None
    n=re.search(r'name="([^"]*)"',l); d['name']=n.group(1) if n else ''
    r=re.search(r'races=\{([^}]*)\}',l); d['races']=re.findall(r'"([^"]+)"',r.group(1)) if r else None
    c=re.search(r'classes=\{([^}]*)\}',l); d['classes']=re.findall(r'"([^"]+)"',c.group(1)) if c else None
    tg=re.search(r'target=\{kind="(\w+)", id=(\d+)',l); d['tk'],d['tid']=(tg.group(1),int(tg.group(2))) if tg else (None,None)
    d['n']=len(steps)+1
    steps.append(d)
RACE={'orc':2,'undead':5,'tauren':6,'troll':8,'skyborne':96}
CLS={'warrior':1,'paladin':2,'hunter':3,'rogue':4,'priest':5,'shaman':7,'mage':8,'warlock':9,'druid':11}
COMBOS={'orc':['warrior','hunter','rogue','shaman','warlock','mage'],'troll':['warrior','hunter','rogue','priest','shaman','mage','warlock'],
 'tauren':['warrior','hunter','shaman','druid'],'undead':['warrior','rogue','priest','mage','warlock','paladin'],'skyborne':['warrior','hunter','rogue','shaman','druid']}
HORDE=2|16|32|128
def applies(s,race,cls):
    if s['races'] and race not in s['races']: return False
    if s['classes']:
        neg=[c[1:].lower() for c in s['classes'] if c.startswith('!')]
        pos=[c.lower() for c in s['classes'] if not c.startswith('!')]
        if cls in neg: return False
        if pos and cls not in pos: return False
    return True
def raceok(mask,race):
    if not mask: return True
    if race=='skyborne': return mask & HORDE != 0 or mask & (1<<33) != 0 or mask==0
    return mask & (1<<(RACE[race]-1)) != 0
def classok(mask,cls):
    return not mask or mask & (1<<(CLS[cls]-1)) != 0
issues=collections.defaultdict(set)
def add(kind,s,msg,who): issues[(kind,s['n'],s['t'],s['q'],s['name'],msg)].add(who)
missing=set()
for race,clss in COMBOS.items():
  for cls in clss:
    who=f"{race} {cls}"
    lst=[s for s in steps if applies(s,race,cls)]
    turned=set(); accepted=set()
    for s in lst:
        q=s['q']
        if q is None: continue
        rec=Q.get(q)
        if rec is None: missing.add((q,s['name'])); continue
        if s['t']=='A':
            if not raceok(rec.get('requiredRaces'),race): add('wrong race',s,f"QuestieDB race mask {rec.get('requiredRaces')}",who)
            if not classok(rec.get('requiredClasses'),cls): add('wrong class',s,f"QuestieDB class mask {rec.get('requiredClasses')}",who)
            ps=rec.get('preQuestSingle') or []; pg=rec.get('preQuestGroup') or []
            if ps and not any(p in turned for p in ps):
                inroute=[p for p in ps if any(x['q']==p and x['t']=='T' for x in lst)]
                add('prereq not handed in yet',s,f"needs one of {ps}"+(f" (route hands in {inroute} later)" if inroute else " (not in route)"),who)
            for p in pg:
                if p not in turned:
                    later=any(x['q']==p and x['t']=='T' for x in lst)
                    add('prereq not handed in yet',s,f"needs all of {pg}; {p} "+("handed in later" if later else "not in route"),who)
            for e in rec.get('exclusiveTo') or []:
                if e in accepted or e in turned: add('exclusive',s,f"excludes {e}, which the route already took",who)
            b=rec.get('breadcrumbForQuestId')
            if b and (b in accepted or b in turned): add('breadcrumb too late',s,f"breadcrumb for {b}, already accepted",who)
            sb=rec.get('startedBy') or []
            if s['tk']=='npc' and sb and sb[0] and s['tid'] not in sb[0]: add('wrong giver',s,f"route NPC {s['tid']}, QuestieDB starters {sb}",who)
            if s['tk']=='object' and sb and len(sb)>1 and sb[1] and s['tid'] not in sb[1]: add('wrong giver',s,f"route object {s['tid']}, QuestieDB {sb}",who)
            accepted.add(q)
        elif s['t']=='T':
            if q not in accepted: add('hand-in without pick-up',s,"",who)
            fb=rec.get('finishedBy') or []
            if s['tk']=='npc' and fb and fb[0] and s['tid'] not in fb[0]: add('wrong hand-in NPC',s,f"route NPC {s['tid']}, QuestieDB enders {fb}",who)
            turned.add(q)
        elif s['t']=='C':
            if q not in accepted: add('complete without pick-up',s,"",who)
print("Quest IDs not in QuestieDB:",len(missing))
for m in sorted(missing): print("  ",m)
bykind=collections.defaultdict(list)
for k,v in issues.items(): bykind[k[0]].append((k,v))
for kind,items in bykind.items():
    print(f"\n== {kind}: {len(items)}")
    for k,v in sorted(items,key=lambda x:x[0][1]):
        w=sorted(v); w="ALL" if len(w)>=27 else ", ".join(w) if len(w)<=4 else f"{len(w)} race/class combos"
        print(f"  step {k[1]} {k[2]} {k[3]} {k[4]}: {k[5]}  [{w}]")

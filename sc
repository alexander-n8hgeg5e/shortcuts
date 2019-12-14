#!/usr/bin/python3


from subprocess import getoutput,Popen
from subprocess import call
from os import environ as env
from functools import cmp_to_key
from os import listdir,mkdir,unlink
from socket import gethostname
from signal import signal as _signal
from signal import SIGINT,SIGKILL,SIGHUP,SIGQUIT,SIGTERM
quitsignals=[SIGINT,SIGKILL,SIGHUP,SIGQUIT,SIGTERM]
from sys import exit,argv

positionsdir = env["HOME"]+"/.conky_run"
try:
    mkdir(positionsdir)
except FileExistsError:
    pass

positions_config_file = env['HOME'] + "/.conky_positions"

conky_conf_dir=env['HOME'] + '/.config/conky'

dlist=None

with open(positions_config_file,mode='rt') as pcf:
    code=pcf.read()
    conky_layout = eval(code)


def startswith(string,startstring):
    return string[0:len(startstring)] == startstring

def endswith(string,endstring):
    return string[-len(endstring):] == endstring

def screennum( line ):
    word = "Screen "
    pos = line.find(word)
    numstart = len(word) + pos
    #print(line[numstart:])
    numend  = numstart + line[numstart:].find(' ') - 1 
    return int(line[numstart:numend])

def plist(l):
    for i in l:
        print(i)
    
    
def __prepare_lines(outp):
    """
    does nothing useful yet
    """
    lines=[]
    for i in outp:
        lines.append(i)
    return lines

def __parse_screen_lines_stage1(lines):
    """
    ret list of screens containing lists with corresponding lines
    """
    screen_lines = []
    l=[]
    capture=False
    for line in lines:
        if startswith(line,"Screen"):
            capture = True
            if len(l) > 0:
                 screen_lines.append(l)
                 l=[]
        else:
            if capture and line[0]!=" ":
                l.append(line)
    screen_lines.append(l)
    return screen_lines
    
def __prepare_layout_list(screen_lines):
    """
    Takes the screen lines and
    makes a list with dicts ( "the layout" )
    A list entry is a dict that will
    contain the information of screen.
    """
    layout=[]
    for i in range(len(screen_lines)):
        layout.append( {} )
    return layout
        
def __parse_screen_lines_stage2(screen_lines):
    """
    Parses stuff from (xrandr) screen lines and puts into layout.
    layout and screen_lines are lists with same lenght and
    corresponding entries at same index position.
    """
    layout=__prepare_layout_list(screen_lines)
    for i in range(len(layout)):
        for j in screen_lines[i]:
            if j[0] is not " ":
                d={}
                words = j.split(" ")
                output_name = words[0]
    
                connected = (words[1]== "connected")
                d.update({ "connected" : connected })
    
                if words[2] == "primary":
                    d.update({"primary": True})
                    pos_str= words[3]
                    rotate =  (words[4].strip() == "left" or words[4].strip() == "right")
                else:
                    d.update({"primary": False})
                    pos_str= words[2]
                    rotate = (words[3].strip() =="left" or words[3].strip() == "right")

                d.update({"rotate" : rotate})
    
                pos = tuple(pos_str.split("+")[1:])
                d.update({ "pos" : pos })
    
                size = tuple(pos_str.split("+")[0].split('x'))
                d.update({ "size" : size })
    
                layout[0].update( { output_name : d } )
    return layout

def parse_layout():

    outp = getoutput([ 'xrandr' ]).splitlines()

    lines = __prepare_lines(outp)

    screen_lines=__parse_screen_lines_stage1(lines)

    layout=__parse_screen_lines_stage2(screen_lines)

    return layout

def get_connected_outputs_of_screen(layout,screen_num):
    scl=layout[screen_num]
    co=[]
    for outp in scl.keys():
            if scl[outp]['connected']:
                co.append(scl[outp])
    return co 


def get_connected_outputs_sorted_left_to_right(layout,screen_num):
    connected_outputs=get_connected_outputs_of_screen(layout,screen_num)
    o=connected_outputs
    def sortkey(d):
        return int(d['pos'][0])
    return sorted(o,key=sortkey)

def get_primary_index(outputlist):
    for i in range(len(outputlist)):
        if outputlist[i]['primary']:
            return i 
    

def scan_available_conky_confs():
    content=listdir(conky_conf_dir)
    c=[]
    for fn in content:
        prefix='conky'
        suffix='.conf'
        if startswith(fn,prefix) and endswith(fn,suffix):
            # filename ok
            middle = fn[len(prefix):-len(suffix)]
            c.append( { middle.strip('_')  :  conky_conf_dir+ '/'+ fn})
    return c

def gen_conky_pos_list(conky_layout,connected_ouputs_count,reset=False):
    args_list=[]
    all_hostnames = []
    hostname_ = gethostname()

    for line in conky_layout:

        conky_id   = line[0]
        outp       = line[1]
        align      = line[2]
        hostslist  = line[3]

        # collect all hostnames
        for i in hostslist:
            if i not in all_hostnames:
                all_hostnames.append(i)

        x_off = line[4]
        y_off = line[5]

        display    = line[6]

        if not is_conky_running_on_pos(outp, align, x_off, y_off ,display,reset=reset,all_hostnames=all_hostnames):
            for hostname in hostslist:
                if hostname == hostname_:
                    consider_entry_to_append=[ conky_id ,  outp , align , x_off, y_off, hostname, display ]
                    if not is_conkys_with_same_config_near_position( args_list, conky_id, outp , align , hostname, display , reset=reset):
                        args_list.append(consider_entry_to_append)
                        # break the hostname loop
                        break
    return args_list

def is_conkys_with_same_config_near_position( conky_pos_list , conky_id, outp , align , hostname , display, reset=False):
    for i in conky_pos_list:
        if conky_id == i[0] and outp == i[1] and align == i[2] and hostname == i[5] and display == i[6]:
            return True
    if not reset:
        global dlist
        if dlist is None:
            dlist = listdir(positionsdir)
        for i in dlist:
            p=i.find(str(outp)+ '_'+ str(align) + "_")
            if not p is -1:
                if i[p:].find("_"+str(hostname)) is not -1:
                    return True 
    return False
    

def mark_conky_as_started(pos_list_entry):
    pe=pos_list_entry
    with open(positionsdir+"/"+ str(pe[1])+'_'+str(pe[2])+"_"+str(pe[3])+"_"+str(pe[4])+"_"+str(pe[5]) ,mode="wt") as f:
        pass  

def is_conky_running_on_pos(outp,align,x_off,y_off,display,reset=False,all_hostnames=None):
    global dlist
    if dlist is None:
        dlist = listdir(positionsdir)
    for i in all_hostnames:
        _str=str(outp)+'_'+str(align)+"_"+str(x_off)+"_"+str(y_off)+"_"+display+"_"+i
        if _str in dlist:
                return True
    return False

def gen_args_for_conky(pos_list_entry, primary_index, connected_outputs_list,magic_enabled=False):
    #print(connected_outputs_list)
    p = primary_index
    e=pos_list_entry
    o=connected_outputs_list
    args=[]

    args.append('-d')

    args.append('-c')
    # reconstruct the filename
    if e[0]=='':
        fn = ''
    else:
        fn= '_' + e[0]
    fn = conky_conf_dir +'/' + 'conky' + fn + '.conf'
    args.append( fn )

    # alignment
    if not e[2]=='':
        args.append('-a')
        args.append( e[2] )

    # pos offset depends on primary and size
    # outp index 
    outp_index = e[1]
    oi = outp_index

    # begin magic
    if oi != p and magic_enabled:
        if oi > p:
            if not o[oi-1]['rotate']:
                x_off = - int(o[oi]['size'][0])
            else:
                x_off = + int(o[oi]['pos'][0]) + int(o[-oi]['size'][0]) - 40
            if e[2][0]=='b':
                  y_off = -  ( int(o[oi]['size'][1]) - int(o[oi-1]['size'][1]))
            elif e[2][0]=='t':
                  y_off = 0
        elif oi < p:
            x_off = + int(o[oi]['pos'][0]) + int(o[-oi]['size'][0]) - 40
    else:
        #x_off=o[oi]['size'][0]
        x_off=0
        y_off=0
        
    args.append('-x')
    args.append( str(x_off+e[3]) )
    args.append('-y')
    args.append( str(y_off+e[4]) )

    return args
        
        
def gen_args_for_conky_v2(p,o):
    args=[]

    args.append('-c')
    # reconstruct the filename
    if p[0]=='':
        fn = ''
    else:
        fn= '_' + p[0]
    fn = conky_conf_dir +'/' + 'conky' + fn + '.conf'
    args.append( fn )

    args.append( gen_pos_args_for_conky(p,o) )

    return args

def prepare_data(p,o):
    l=[]
    for d in o:
        if 'connected' in d.keys():
            d.pop('connected')
    p.pop(0)
    inp=[]
    for i in p:
        inp.append(i)
    for d in o:
        for k in d.keys():
            inp.append(d[k])
    return inp


def gen_world():
    w=[]
    w.append("bool" , inv  )
    w.append("bool" , add  )


def add(a):
     if a:
         return [True,True]
     else:
         return [False,False]

def inv(a):
    return not(a)

def int_to_bool(a):
    s=bin(a)[2:]
    r=[]
    for i in range(len(s)):
        r.append(not(bool(int(s))))
    return r
        
def gen_pos_args_for_conky(p,o):
    data=prepare_data(p,o)
    #print()
    #print(data)
    #print()
    operations=gen_operations()

def _signal_handler(sig,frame):
    global conkys
    print('exit due to signal: '+str(sig))
    for c in conkys:
        c.send_signal(sig)
        
def killall_conkys():
    call(["killall","conky"])
    
def unlink_entrys():
    global dlist
    if dlist is None:
        dlist=listdir(positionsdir)
    hostname=gethostname()
    for i in dlist:
        if i.find(hostname) != -1:
            unlink(positionsdir+"/"+i)         
    dlist=listdir(positionsdir)


def main():
    global conkys
    lo=parse_layout()
    o=get_connected_outputs_sorted_left_to_right(lo,0)
    p=get_primary_index(o)
    cc=scan_available_conky_confs()
   # print('detected conky confs:')
   # print(cc)
   # print()
   # print('detected available outputs')
   # print(o)
   # print()
   # print('primary outp: '+str(p))
   # print()
    reset=False
    if len(argv) > 1:
        if "-r" in argv[1:] or "-k" in argv[1:]:
            reset=True
            unlink_entrys()
            killall_conkys()
        if "-k" in argv[1:]:
            exit(0)
    pl = gen_conky_pos_list(conky_layout,len(o),reset=reset)
    #print(pl)
    conkys=[]
    for i in pl:
        a = gen_args_for_conky(i,p,o)
        cmd = ['conky'] + a
        print(cmd)
        mark_conky_as_started(i)
        e=env.copy()
        e.update({'DISPLAY': i[6]})
        conkys.append(Popen( cmd,env=e))
    #for j in quitsignals:
    #     _signal(j,_signal_handler)
    for c in conkys:
          c.wait()
main()

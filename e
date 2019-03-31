#!/usr/bin/python3
waitmsg='>> waiting for ANYKEY <<'
from logging import INFO, DEBUG, WARNING
LOGLEVEL=WARNING
EWMH_SUPPORT=True
socketfile='/tmp/ioufoiusufiosur'

#####   logging   ########################
try:
    from logging import Formatter as LogFormatter
    from logging import getLogger
    #from logging.handlers import RotatingFileHandler
    from logging import StreamHandler
except KeyboardInterrupt as e: raise e
except Exception         as e: print(e)
try:
    l=getLogger('root')
    #handler = RotatingFileHandler(co.LOGFILE, mode='a', maxBytes=1024*1024, backupCount=2, encoding=None, delay=False)
    #handler = SysLogHandler( facility = "user")
    handler = StreamHandler()
    handler.setLevel( LOGLEVEL )
    l.setLevel(       LOGLEVEL )
    handler.setFormatter( LogFormatter( '%(asctime)s %(levelname)s %(funcName)s: %(message)s' ) )
    l.addHandler(handler)
except KeyboardInterrupt as e: raise e
except Exception         as e: print(e)

######     imports        ##############
from sys import argv
from sys import exit
from os import environ
from os.path import abspath,isdir,exists,split,basename,isdir,stat
from os.path import join as pathjoin
from os import mkdir
from os import stat as stat_file
from columnize import columnize as col
import neovim
from subprocess import getstatusoutput
have_sockets = False
sockets=None
generated_focused_nvims_list=False
generated_monitor_positions_list=False
nvims=None

import argparse
parser=argparse.ArgumentParser( description="opens file in new nvim tab")
parser.add_argument("-w","--wait", action="store_true", help= "Wait until confirmationn by a keypress after opening the file/s" )
parser.add_argument("-c","--confirm-by-buffer-unload", action="store_true", help = "Wait until confirmirmation that the editing is done by checking whether the buffer is closed and furter the calling terminal buffer is in insert mode." )
parser.add_argument( "-b",'--back',action="store_true", help="instruct nvim to go back to terminal window, after buffer is closed. This only works if a single file is specified." )
parser.add_argument( "-v",'--verbose',action="store_true", help="be verbose and so tell the sockets" )
parser.add_argument( "-s",'--select-socket',action="store", type=int , default=0 , help="scan nvim sockets and use number of found socket, 0 is the last opened nvim")
parser.add_argument( "-1", action='store_const', const=1 , dest='select_socket', help="same as -s1")
parser.add_argument( "-d",'--debug',action="store_true", help="enable debug logging")
parser.add_argument( "-t",'--new-tab',action="store_true", help="open in new tab in every case")
parser.add_argument( "--testing",action="store_true", help="testing mode, runs some hardcoded func during develpement")
parser.add_argument( "-g",'--guess', action="store_true",  default=False, help="do guessing things")
parser.add_argument( "--scan", action="store_true",  default=False, help="only scan and write a socket list file")
parser.add_argument('files', metavar='files', nargs='+', type=str, help='files to open')
##parser.add_argument()

def d(msg):
    l.debug(msg)

def is_sock(path):
    return stat.S_ISDIR(stat_file(path).st_mode)

def is_prob_nvim_sock(path):
            exit_code , output = getstatusoutput(["lsof "+ path])
            if int(exit_code) == 0 and output[0:4].find("nvim"):
                return True
            else:
                return False

def get_paths_of_all_sockets():
    global sockets
    if not have_sockets:
        scan_for_sockets()

def nvim_is_focused_win( socket ):
    for i in range(len(sockets)):
        if sockets[i] == socket:
            return focus_of_nvim_by_sock[i]
    

def gen_monitor_positions_list(mode=0):
    """
    Connects the neovims via sockets in socket-list and returns unreliable list with screen positions in the same order.
    positions are: "r" , "l"
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values
    """
    # var to update
    global pos_of_nvim_by_sock
    if mode==0 and generated_monitor_positions_list:
        return
    if mode==1:
        if generated_focused_nvims_list:
            if len(pos_of_nvim_by_sock) == len(sockets):
                return
    positions=[]
    attach_em(mode=0)
    win_width       = int(nvims[0].call('system','xdotool getactivewindow getwindowgeometry|grep Geometry:|cut -d: -f2|string trim|cut -dx -f1'))
    x_pos_left_edge = int(nvims[0].call('system','xdotool getactivewindow getwindowgeometry|grep Position:|cut -d: -f2|string trim|cut -d, -f1'))
    x_pos = x_pos_left_edge + win_width / 2 # so x-center of win defines where the win is
    left_monitor_witdh = int(environ['left_monitor_width'])
    if x_pos > left_monitor_witdh:
        activewin='r'
        # right
    elif x_pos <= left_monitor_witdh:
        activewin='l'
        # left
    else:
        # undefined
        activewin=None
    gen_focused_nvims_list(mode=1)
    for j in range(len(sockets)):
        if activewin is 'r' and nvim_is_focused_win(sockets[j]):
            positions.append('r')
        elif activewin is 'l' and nvim_is_focused_win(sockets[j]):
            positions.append('l')
        else:
            positions.append('_')
    pos_of_nvim_by_sock = positions
        
            

def gen_focused_nvims_list(mode=0):
    """
    Connects the neovims via sockets in socket-list and returns unreliable list with focused win state.
    States are True means focus, or False means no focus.
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values
    """
    # var to update
    global focus_of_nvim_by_sock
    if mode==0 and generated_focused_nvims_list:
        return
    if mode==1:
        if generated_focused_nvims_list:
            if len(focus_of_nvim_by_sock) == len(sockets):
                return
    states=[]
    attach_em(mode=0)
    for j in range(len(sockets)):
        active_win = int(nvims[j].call( 'system', 'xdotool getwindowfocus' ))
        nvim_win = int( nvims[j].call( 'expand',"$WINDOWID" ))  # luckily some of my progs saves this to the env
        if active_win == nvim_win:
            states.append(True)
            l.debug('socket: '+ sockets[j] +'  belongs to active nvim window')
        else:
            states.append(False)
            l.debug('socket: '+ sockets[j] +'  belongs to inactive nvim window')
    focus_of_nvim_by_sock = states
            

def attach_em(mode=0):
    """
    attach neovim interfaces to the global sockets and set the global nvims
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values
    """
    # var to update
    global nvims
    if mode==0 and nvims is not None:
        return
    if mode==1:
        if nvims is not None:
            if len(nvims) == len(sockets):
                 return
    gen_socketlist(mode=0)
    nvims=[]
    for i in range(0,len(sockets)):
        nvims.append(neovim.attach('socket',path=sockets[i]))

def gen_socketlist(mode=0):
    """
    if unset ,sets the global sockets list
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values
    """
    # var to update
    global sockets
    if mode==0 and sockets is not None:
        return
    if mode==1 and have_sockets:
        return
    global socket_index_to_connect
    if args.select_socket > 0:
        load_or_scan_sockets()
    else:
        if not have_sockets:
            envsock = environ['NVIM_LISTEN_ADDRESS']
            if is_prob_nvim_sock(envsock) and args.guess and mode==0:
                   v('use likely right sock: '+envsock)
                   sockets = [ envsock ]
            else:
                v('need socket scan, env var lsof check failed: '+envsock)
                load_or_scan_sockets()
                
def decide_for_socket_to_connect():
    # need some sockets
    gen_socketlist(mode=0)
    # default fallback
    global socket_index_to_connect
    socket_index_to_connect=0
    global open_other_monitor
    open_other_monitor=False
    # decide
    if len(sockets)==1:
        return
    else:
        # more than one sock, so need proper scan
        gen_focused_nvims_list(mode=1)
        gen_monitor_positions_list(mode=1)
        l.debug('socket: '+str(args.select_socket))
        done=False
        if args.select_socket==0:
            # want to connect to current monitor nvim
            l.debug('want to connect to curren monitors nvim')
            for i in range(len(sockets)):
                if focus_of_nvim_by_sock[i]:
                    socket_index_to_connect = i
                    open_other_monitor=False
                    return
        elif args.select_socket >= 1:
            # want to connect to other monitor nvim, so skip same monitor and own socket
            l.debug('want to connect to other monitors nvim')
            pos_of_focused_nvim=None
            # get pos of the focused window
            for i in range(len(sockets)):
                if focus_of_nvim_by_sock[i]:
                     pos_of_focused_nvim = pos_of_nvim_by_sock[i]
            for j in range(1,args.select_socket+1):
                for i in range(len(sockets)):
                           # not my window                          # not same monitor                           # and count sockets
                    if not focus_of_nvim_by_sock[i] and not pos_of_focused_nvim == pos_of_nvim_by_sock[i] and j == args.select_socket:
                         socket_index_to_connect=i
                         open_other_monitor=True
                         return
            # if not found a window that is on the other monitor...
            # choose the next counter other ones
            if not done:
                l.debug('not found on other')
                for j in range(1,args.select_socket+1):
                    for i in range(len(sockets)):
                        if not focus_of_nvim_by_sock[i] and j == args.select_socket:
                             socket_index_to_connect=i
                             open_other_monitor=False
                             return
        else:
            # want to connect to current monitor nvim
            done=False
            for i in len(sockets):
                if focus_of_nvim_by_sock[i]:
                    socket_index_to_connect = i
                    open_other_monitor = False
                    return

def v(msg, **kwargs):
    if args.verbose:
        print(msg, **kwargs)

def scan_for_sockets():
    v('scanning all sockets',end='')
    global sockets
    from os import listdir
    tmp=listdir("/tmp")
    dirs=[]
    for i in tmp:
        try:
            if i[:4]=="nvim":
                nvim_socket_dir_path=pathjoin("/tmp",i)
                if isdir(nvim_socket_dir_path):
                    #d('dir: '+str(nvim_socket_dir_path))
                    dir_listing=listdir(nvim_socket_dir_path)
                    v('.',end='')
                    for entry in dir_listing:
                        if entry=="0" or entry=='0_remote': # 0 is the expected filename
                            socketpath = pathjoin(nvim_socket_dir_path,entry)
                            if is_prob_nvim_sock(socketpath):
                                dirs.append(socketpath)
                        v('.',end='')
        except PermissionError as e:
            l.info(e)
    v(('.done'))
    sockets = dirs
    f=open(socketfile,mode='wt')
    for socket in sockets:
         f.write(socket)
         f.write('\n')
    f.close()
    have_sockets = True

def load_or_scan_sockets():
    global sockets
    sockets=[]
    if exists(socketfile):
        f=open(socketfile,mode='rt')
        for line in f.readlines():
            sockets.append(line.strip())
    else:
        scan_for_sockets()
    l.debug(sockets)

def remote():
    bn=basename(sockets[0])
    if bn[0:18]=="nvim_forward_from_":
        return True

def get_remote_hostname():
    a=basename(sockets[0])[18:]
    pos=a.find('_')
    hostname=a[:pos]
    print(hostname)
    if len(hostname)==0:
        raise Exception("error1")
    return hostname 
    
def makedir(path):
    """
    Makes a dir if needed for the file addressed with path.
    If the path is already a dir, nothing happens. 
    """
    thing=abspath(path)
    thing=split(abspath(path))[0] # assuming thing is always a a dir or not existing
    if not exists(thing):
        mkdir(thing)

def autowait(first_file_arg):
    # don't wait for pass prog. It don't like it, or so.
    if (not first_file_arg.find("pass") is -1) and (not first_file_arg.find("shm") is -1):
        wait()

def wait():
    from sys import stdin
    from tty import setcbreak,tcsetattr,TCSADRAIN,tcgetattr
    old=tcgetattr(stdin)
    setcbreak(stdin)
    print(waitmsg)
    a=stdin.read(1)
    tcsetattr(stdin, TCSADRAIN, old)
    
def gen_target_desktop():
    """
    target desktop like wmctrl undstands desktops
    """
    # use nvim to run cmd because its already running and has display vars, etc. set
    global target_desktop
    outp=nvims[ socket_index_to_connect ].call( 'system' ,'wmctrl -l' )
    outp_lines = outp.splitlines()
    for line in outp_lines:
        l.debug('line: '+line)
        hex_string= hex(int(target_window))
        while len(hex_string) < 10:
            hex_string = hex_string[0:2]+'0'+hex_string[2:]
        f = line.find( hex_string )
        l.debug(hex_string)
        if f is not -1:
            l.debug("found line: "+line)
            target_desktop = line.split()[1]
            
def nvim_open_file(file):
    makedir(file)
    if isdir(file) and args.select_socket == 0 and not args.new_tab:
        pass
    else:
        nvims[ socket_index_to_connect ].call('EventWinLeave')
        nvims[socket_index_to_connect].command('tabnew')
    if not remote(): 
        nvims[socket_index_to_connect].command( 'e '+abspath(file) )
    else:
        from platform import node
        hostname=node()
        remotehost=get_remote_hostname()
        path_on_remote='/mnt/'+hostname+abspath(file)
        nvims[socket_index_to_connect].command( 'e '+path_on_remote)
    l.debug(open_other_monitor)
    if open_other_monitor:
        l.debug( pos_of_nvim_by_sock )
        if pos_of_nvim_by_sock[ socket_index_to_connect ] == 'r':
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+f')
        elif pos_of_nvim_by_sock[ socket_index_to_connect ] == 'l':
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+s')
        else:
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+f')

def gen_target_window_id():
    global target_window
    target_window = nvims[socket_index_to_connect].call( 'system' , 'echo $WINDOWID' )

### main code
args=parser.parse_args()
if args.debug:
    l.setLevel( DEBUG )
    for i in l.handlers:
        i.setLevel( DEBUG )
    l.debug('debugging enabled')

if args.scan:
    scan_for_sockets()
    exit()

decide_for_socket_to_connect()
attach_em()

if args.verbose:
    col_opts = \
    {'arrange_array': False,
     'arrange_vertical': True,
     'array_prefix': '',
     'array_suffix': '',
     'colfmt': None ,
     'colsep': ' | ',
     'displaywidth': 40,
     'lineprefix': '',
     'linesuffix': '\n',
     'ljust': None,
     'term_adjust': False}
    gen_focused_nvims_list()
    gen_monitor_positions_list()
    print_list = ['socket','-----------------']  + sockets + ['focused','-------'] + focus_of_nvim_by_sock +['pos','---'] + pos_of_nvim_by_sock
    print( col( print_list , opts=col_opts ))

if args.testing:
    gen_target_window_id()
    l.debug( target_window )
    gen_target_desktop()
    l.debug("dnum: "+ target_desktop )
    raise Exception('done')

# go back phase 1
global back
back=False
if args.back: 
    if len(args.files) == 1:
        # store winid of inside nvim
        global nvim_win_id
        nvim_win_id = nvims[ socket_index_to_connect ].call( 'win_getid' )
        # remember want to get back
        back=True
    else:
        l.error("winback works only with single file")

# open files,tabs and whatever
for i in args.files:
   nvim_open_file(i)

# go back phase 2
if back:
    l.debug("setup go back stuff")
    # this after all win and buffer openening configures the way back
    nvims[socket_index_to_connect].command( "augroup winback")  #start group
    nvims[socket_index_to_connect].command( "au! winback")  #delete the aucmds
    if not open_other_monitor:
          nvims[socket_index_to_connect].command( "au BufUnload <buffer> call win_gotoid("+str(nvim_win_id)+")" )  # finally assign the buffer local autocmd to the group
    elif open_other_monitor:
          nvims[socket_index_to_connect].command( "au BufUnload <buffer> call system('xdotool key --clearmodifiers ctrl+alt+f')")
    nvims[socket_index_to_connect].command( "augroup end")                  # end group so can be deleted

if args.wait:
    wait()
else:
    autowait(args.files[0])

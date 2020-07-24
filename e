#!/usr/bin/python3
waitmsg='>> waiting for ANYKEY <<'
from logging import INFO, DEBUG, WARNING
LOGLEVEL=WARNING
EWMH_SUPPORT=True
socketfilebase='/tmp/ioufoiusufiosur'
socketfile=None
hostname=None
pagerfilepath='/dev/shm/pagerfile'

#####   logging   ########################
try:                            #{{{
    from logging import Formatter as LogFormatter
    from logging import getLogger
    #from logging.handlers import RotatingFileHandler
    from logging import StreamHandler
except KeyboardInterrupt as e: raise e
except Exception         as e: print(e)
try:
    l=getLogger('root')
    l.handlers=[]
    #handler = RotatingFileHandler(co.LOGFILE, mode='a', maxBytes=1024*1024, backupCount=2, encoding=None, delay=False)
    #handler = SysLogHandler( facility = "user")
    handler = StreamHandler()
    handler.setLevel( LOGLEVEL )
    l.setLevel(       LOGLEVEL )
    handler.setFormatter( LogFormatter( '%(asctime)s %(levelname)s %(funcName)s: %(message)s' ) )
    l.addHandler(handler)
except KeyboardInterrupt as e: raise e
except Exception         as e: print(e)        #}}}

######     imports        ##############
#{{{
from sys import argv,stdin
from sys import exit
from os import environ,isatty
from os.path import abspath,isdir,exists,split,basename,isdir,stat
from os.path import join as pathjoin
from os import mkdir
from os import stat as stat_file
import neovim
from subprocess import getstatusoutput,DEVNULL #}}}

#####      setup global vars   #####
#{{{
have_sockets = False
sockets=None
generated_focus_of_nvim_by_socketnum_list=False
generated_incomplete_monitor_positions_list=False
nvims=None
back=False
generated_pos_of_nvim_by_sock_list=False
generated_pos_of_nvim_by_sock=False
generated_monitor_widths=False
generated_visible_win_list=False
generated_nvims_visible_state_by_socket=False
generated_win_id_list_by_socket_index=False
generated_visible_nvims_list=False
generated_screens=False
generated_xservers_dict_and_sock2xserver_list=False
generated_x_display_list=False
generated_win_id_to_geom_dict=False
generated_win_id_xserver_dict_list_by_socket_index=False

try:
    eroot=environ["EROOT"]
except KeyError:
    eroot='/'
# }}}

#####    parse args     ######
#{{{
import argparse
parser=argparse.ArgumentParser( description="opens file in new nvim tab")
parser.add_argument("-w","--wait", action="store_true", help= "Wait until confirmationn by a keypress after opening the file/s" )
parser.add_argument("-c","--confirm-by-buffer-unload", action="store_true", help = "Wait until confirmirmation that the editing is done by checking whether the buffer is closed and furter the calling terminal buffer is in insert mode." )
parser.add_argument( "-b",'--back',action="store_true", help="instruct nvim to go back to terminal window, after buffer is closed. This only works if a single file is specified." )
parser.add_argument( "-v",'--verbose',action="store_true", help="be verbose and so tell the sockets" )
parser.add_argument( "-s",'--select-socket',action="store", type=int , default=0 , help="scan nvim sockets and use number of found socket, 0 is the last opened nvim")
parser.add_argument( "-1", action='store_const', const=1 , dest='select_socket', help="same as -s1")
parser.add_argument( "-d",'--debug',action="store_true", help="enable debug logging")
parser.add_argument( "-C",'--command',action="store", default=None, help="run this command in the somehow choosen nvim")
parser.add_argument( '--git',action="store_true", help="use settings for edit git things. Commits and like that.")
parser.add_argument( "-t",'--new-tab',action="store_true", help="open in new tab in every case")
parser.add_argument( "--testing",action="store_true", help="testing mode, runs some hardcoded func during develpement")
parser.add_argument( "-g",'--guess', action="store_true",  default=False, help="do guessing things")
parser.add_argument( "--scan", action="store_true",  default=False, help="only scan and write a socket list file")
parser.add_argument('files', nargs='*', default=[] , type=str, help='files to open')
##parser.add_argument()   #}}} 

def d(msg):
    pass   #{{{
    l.debug(msg)   #}}} 

def gen_screens():
    global generated_screens   #{{{
    global screens
    global screen_layout
    if generated_screens and mode is 0:
        return
    if generated_screens and mode is 1:
        return
    global screen_utils
    from pylib.screen_utils.env import parse_screen_layout_env_var_v3
    screen_layout=parse_screen_layout_env_var_v3()
    screens=screen_layout
         
def is_sock(path):
    return stat.S_ISDIR(stat_file(path).st_mode)   #{{{   #}}} 

def get_hostname():
    global hostname   #{{{
    if hostname == None:
        from platform import node
        hostname=node()
    return hostname   #}}} 

def is_prob_nvim_sock(path):
            exit_code , output = getstatusoutput(["lsof "+ path])   #{{{
            if int(exit_code) == 0 and output[0:4].find("nvim"):
                return True
            else:
                return False   #}}} 

def gen_visible_win_list(mode=0):
    global generated_visible_win_list   #{{{
    global visible_win_list
    focused_nvim_index_ = focused_nvim_index()
    if generated_visible_win_list and mode==0:
        return
    if generated_visible_win_list and mode==1:
        return

    attach_nvims()

    visible_win_list=[]
    generated_visible_win_list=True   #}}} 

def gen_xservers_dict_and_sock2xserver_list(mode=0):
    """   #{{{
    xservers := {"display_string" : [list_of_nvim_socket_indexes] }
    """
    global generated_xservers_dict_and_sock2xserver_list
    global xservers
    global sock2server_list
    if generated_xservers_dict_and_sock2xserver_list and mode is 0:
        return
    if generated_xservers_dict_and_sock2xserver_list and mode is 1:
        return
    gen_screens()
    gen_win_id_list_by_socket_index()
    xservers={}
    sock2server_list=[]
    for i in screen_layout:
        sock2server_list.append(s)
        if not s in xservers.keys():
            xservers.update( { s : [i] } )
        else:
            xservers[s].append(i)
    generated_xservers_dict_and_sock2xserver_list=True   #}}} 

def gen_x_display_list(mode=0):
    """   #{{{
    """
    global generated_x_display_list
    global x_display_list
    gen_screens()
    if generated_x_display_list and mode is 0:
        return
    if generated_x_display_list and mode is 1:
        return
    x_display_list=[]
    for screen in screen_layout:
        if screen['x_server'] not in x_display_list:
            x_display_list.append(screen['x_server'])
    generated_x_display_list=True   #}}} 

def gen_win_id_to_geom_dict(mode=0):
    """   #{{{
    """
    global generated_win_id_to_geom_dict
    if generated_win_id_to_geom_dict and mode is 0:
        return
    if generated_win_id_to_geom_dict and mode is 1:
        return
    gen_screens()
    gen_win_id_list_by_socket_index()
    win_id_to_geom_dict={}
    for winid in win_id_list_by_socket_index:
        win_id_to_geom_dict.update({winid:xdotool_utils.get_win_geometry(str(winid))})

    generated_win_id_to_geom_dict=True   #}}} 

def gen_nvims_visible_state_by_socket(mode=0):
    global generated_nvims_visible_state_by_socket   #{{{
    if generated_nvims_visible_state_by_socket and mode is 0:
        return
    if generated_nvims_visible_state_by_socket and mode is 1:
        return
    global nvims_visible_state_by_socket
    nvims_visible_state_by_socket=[]
    gen_visible_win_list()
    gen_win_id_list_by_socket_index()
    for socket_index in range(len(win_id_list_by_socket_index)):
        state=False
        for visible_win in visible_win_list:
            # visible_win := ( server_display_string , win_id )
            servermatch = visible_win[0] == sock2server_list[socket_index]
            win_id_match = visible_win[1] == win_id_list_by_socket_index[socket_index]
            if servermatch and win_id_match: 
                #l.debug("found")
                state=True
        nvims_visible_state_by_socket.append(state)
    generated_nvims_visible_state_by_socket=True   #}}} 

def list2int(l):
    d(l)
    r=[]   #{{{
    for i in l:
        r.append(int(i))
    return r   #}}} 

def nvim_is_focused_win( socket ):
    for i in range(len(sockets)):   #{{{
        if sockets[i] == socket:
            return focus_of_nvim_by_socketnum_list[i]   #}}} 
   
def sum_of_list(l):
    sum=0   #{{{
    for i in l:
        sum = sum + i
    return sum   #}}} 

def __get_active_win_pos_str(count_most, isleft = None):
    ret=''   #{{{
    for i in range(count_most):
        if isleft:
            ret = ret + 'l'
        elif not isleft:
            ret = ret + 'r'
        else:
            raise Exception("isleft is not left nor right,... ")
    return ret   #}}} 

def get_active_win_pos():
    """   #{{{
    returns the horizontal center pos of win as int
    """
    global active_win_id
    global active_win_geo
    global xdotool_utils
    from pylib.xutils import xdotool_utils
    active_win_id = xdotool_utils.get_active_win_id()
    if active_win_id:
        active_win_geo=xdotool_utils.get_win_geometry(active_win_id)
    return int(active_win_geo['pos'][0])   #}}} 

def get_win_x_pos( xserver, int_win_id ):
    """   #{{{
    returns the horizontal center pos of win as int
    """
    geo=xdotool_utils.get_win_geometry(str(int_win_id),x_display=xserver)
    return int(geo['pos'][0])+int(geo['size'][0]/2)   #}}} 

def gen_sock_2_pos_list():
    cmd=[ '-S', '/tmp/tmux-1000/default', 'list-panes', '-F', '"#{pane_id} #{session_name}"' ]   #{{{   #}}} 

def get_win_pos( x_pos ):
    """   #{{{
    returns the screen of the horizontal x_pos
    """
    gen_monitor_widths(mode=0)
    for monitor_index in range(len(monitor_widths)):
        try:
            if x_pos < sum_of_list(monitor_widths[0:monitor_index+1]):
                #found
                return monitor_index
        except TypeError:
            pass
    return None   #}}} 

def get_win_id_of_nvim_by_socket_index(socketindex):
    gen_win_id_list_by_socket_index()   #{{{
    return win_id_list_by_socket_index[socketindex]   #}}} 

def _get_win_id_of_nvim_by_socket_index(socketindex):
        gen_socketlist_of_nvims(mode=0)   #{{{
        try:
            nvim_win_id = int( nvims[socketindex].eval("$WINDOWID"))
        except ValueError:
            # if for some reason some nvim sockets do return faulty stuff
            nvim_win_id = None
        #l.debug( "nvim_win_id: "+ str(nvim_win_id ))
        return nvim_win_id   #}}} 

def _get_win_id_and_x_display_of_nvim_by_socket_index(socketindex):
        gen_socketlist_of_nvims(mode=0)   #{{{
        for i in x_display_list:
            try:
                nvims[socketindex].command('let $DISPLAY="'+i+'"')
                nvim_win_id =  nvims[socketindex].call('system',['xdotool','getactivewindow'])
                x_display   =  nvims[socketindex].eval('$DISPLAY')
                break
            except ValueError:
                # if for some reason some nvim sockets do return faulty stuff
                nvim_win_id = None
                x_display = None
        return nvim_win_id,x_display   #}}} 

def gen_win_id_list_by_socket_index(mode=0):
    global generated_win_id_list_by_socket_index   #{{{
    global generated_win_id_xserver_dict_list_by_socket_index
    global x_display_list
    global win_id_list_by_socket_index
    if (mode==0) and generated_win_id_list_by_socket_index:
        return
    if (mode==1) and len(generated_win_id_list_by_socket_index) == len(sockets):
        return
    gen_x_display_list()
    win_id_list_by_socket_index=[]
    win_id_xserver_dict_list_by_socket_index=[]
    for socket_index in range(len(sockets)):
            win_id_list_by_socket_index.append(_get_win_id_of_nvim_by_socket_index(socket_index))
            win_id,x_display = _get_win_id_and_x_display_of_nvim_by_socket_index(socket_index)
            if win_id:
                win_id_xserver_dict_list_by_socket_index.append({'win_id':win_id,'x_display':x_display})
    generated_win_id_list_by_socket_index=True
    generated_win_id_xserver_dict_list_by_socket_index=True   #}}} 

def gen_monitor_widths(mode=0):
    """   #{{{
    sets the global monitor width vars.
    So its easier to adress them.
    """
    global monitor_widths
    global generated_monitor_widths
    if ( mode==0 or mode == 1 ) and generated_monitor_widths:
        return
    gen_screens()
    layout=screens
    monitor_widths=[thing['dim'][0] for thing in layout]
    generated_monitor_widths=True   #}}} 

def _get_active_win_pos_str( x_pos, right_border , max_count_x_distance_from_boarder, widths ):
        """   #{{{
        returns a string representing the windows pos if pos is in range.
        r means the rightmost, max_count_x_distance_from_boarder = 0 is enough to find and return this
        l means the leftmost
        ll 2nd leftmost and so on
        width is the list that has all the horizontal screen widths in it.
        x_pos the position in pixel
        """
        for i in range(max_count_x_distance_from_boarder): 
            if x_pos > right_border - sum_of_list( monitor_widths[-(i + 1):]):
                 # is the ( i + 1 ) rightmost one  # first: i=0 , so pos is -(i+1) = -1 means last element 
                 ##l.debug("right")
                 activewin = __get_active_win_pos_str( i+1 , isleft = False)
            elif x_pos < sum_of_list(monitor_widths[0:i+1]):
                # is the (i + 1) leftmost one  # first: i=0 , list range is [0:1] , means first element 
                 ##l.debug("left")
                 activewin = __get_active_win_pos_str( i+1 , isleft = True)
                 ##l.debug( activewin )
                 ##l.debug( 'distance: '+str(i) )
            else:
                 ##l.debug("undefined")
                 # undefined
                 activewin=None
        return activewin   #}}} 
    
def get_active_win_pos_str( x_pos, right_border , widths ):
    """   #{{{
    returns a string representing the windows pos.
    r means the rightmost
    l means the leftmost
    ll 2nd leftmost and so on
    c means center
    width is the list that has all the horizontal screen widths in it.
    x_pos the position in pixel
    """
    if len(monitor_widths) %2 == 0 :
        # even
        active_win_pos_str = _get_active_win_pos_str( x_pos, right_border ,int(len(monitor_widths)/2) , monitor_widths )
    elif len(monitor_widths) %2 == 1 :
        # odd, so spare middle one out
        active_win_pos_str = _get_active_win_pos_str( x_pos, right_border , int( ( len(monitor_widths) -1 ) / 2) , monitor_widths )
        if active_win_pos_str is None:
            # must be center
            active_win_pos_str = 'c'
    else:
        # undefined
        active_win_pos_str=None
    return active_win_pos_str    #}}} 

def gen_pos_of_nvim_by_sock(mode=0):
    """   #{{{
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values unconditionally
    """
    # var to update
    global pos_of_nvim_by_sock
    global generated_pos_of_nvim_by_sock
    if mode==0 and generated_pos_of_nvim_by_sock:
        return
    if mode==1 and generated_pos_of_nvim_by_sock:
            if len(pos_of_nvim_by_sock) == len(sockets):
                return
            
    # gen required stuff
    gen_visible_nvims_list()
    gen_screens()
    gen_monitor_widths()

    pos_of_nvim_by_sock=[]
    right_border = sum_of_list(monitor_widths)
    for nvim_index in visible_nvims_list:
        win_id = get_win_id_of_nvim_by_socket_index(nvim_index)
        d(win_id)
        server = sock2server_list[nvim_index] 
        win_x_pos = get_win_x_pos(server,win_id)
        win_pos_index = get_win_pos(win_x_pos)
        pos=None
        for screen_index in range(len(screens)):
            if win_pos_index == screen_index:
                pos=screen_index
        pos_of_nvim_by_sock.append(pos)
    pos_of_nvim_by_sock = pos_of_nvim_by_sock
    generated_pos_of_nvim_by_sock=True   #}}} 

def gen_visible_nvims_list(mode=0):
    """   #{{{
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values unconditionally
    """
    # var to update
    global visible_nvims_list
    if mode==0 and generated_visible_nvims_list:
        return
    if mode==1 and generated_visible_nvims_list:
            if len(visible_nvims_list) == len(sockets):
                return
    visible_nvims_list=[]
    gen_nvims_visible_state_by_socket()
    for socket_index in range(len(nvims_visible_state_by_socket)):
        if nvims_visible_state_by_socket[socket_index]:
            visible_nvims_list.append(socket_index)   #}}} 

def gen_incomplete_monitor_positions_list(mode=0):
    """   #{{{
    Connects the neovims via sockets in socket-list and returns unreliable list with screen positions in the same order.
    positions are: "r" , "l"
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values unconditionally
    """
    # var to update
    global generated_incomplete_monitor_positions_list
    global pos_of_nvim_by_sock
    if mode==0 and generated_incomplete_monitor_positions_list:
        return
    if mode==1 and generated_incomplete_monitor_positions_list:
            if len(pos_of_nvim_by_sock) == len(sockets):
                return
    positions=[]
    gen_monitor_widths()
    x_pos = get_active_win_pos()
    right_border = sum_of_list(monitor_widths)
    active_win_pos_str = get_active_win_pos_str( x_pos, right_border, monitor_widths )
    gen_focus_of_nvim_by_socketnum_list(mode=1)
    for j in range(len(sockets)):
        if nvim_is_focused_win(sockets[j]):
            positions.append( active_win_pos_str )
        else:
            positions.append('_')
    pos_of_nvim_by_sock = positions
    generated_incomplete_monitor_positions_list=True   #}}} 
            
def gen_pos_of_nvim_by_sock_list(mode=0):
    """   #{{{
    Connects the neovims via sockets in socket-list and returns unreliable list with screen positions in the same order.
    positions are: range(len(monitor widths env var))
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values unconditionally
    """
    return [ "invalid" for s in sockets]  #}}} 

def focused_nvim_index():
    gen_focus_of_nvim_by_socketnum_list(mode=0)   #{{{
    for i in range(len(nvims)):
        if focus_of_nvim_by_socketnum_list[i]:
            return i
    return None   #}}} 

def gen_focus_of_nvim_by_socketnum_list(mode=0):
    """   #{{{
    Connects the neovims via sockets in socket-list and returns list with their focus-state(True/False).
    States are True means focus, or False means no focus.
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values unconditionally
    """
    # var to update
    global focus_of_nvim_by_socketnum_list
    global generated_focus_of_nvim_by_socketnum_list
    if mode==0 and generated_focus_of_nvim_by_socketnum_list:
        return
    if mode==1:
        if generated_focus_of_nvim_by_socketnum_list:
            if len(focus_of_nvim_by_socketnum_list) == len(sockets):
                return
    states=[]
    attach_nvims(mode=0)
    for socket_index in range(len(sockets)):
        ##l.debug("calling xdotool getwindowfocus")
        try:
            active_win = int(nvims[socket_index].call( 'system', 'xdotool getwindowfocus' ))
        except ValueError:
            active_win = None
        try:
            nvim_win = int( nvims[socket_index].call( 'expand' , "$WINDOWID" ))  # luckily some of my progs saves this to the env
        except ValueError:
            # if for some reason some nvim sockets do return faulty stuff
            nvim_win = None
        except IndexError:
            attach_nvims(mode=2)
            nvim_win = int( nvims[socket_index].call( 'expand' , "$WINDOWID" ))  # luckily some of my progs saves this to the env
       ###l.debug("socket_index: " + str(socket_index))
       ###l.debug("socket: " + str(sockets[socket_index]))
       ###l.debug("get win id: "+ nvims[socket_index].call( 'expand' , "$WINDOWID" ))
       ###l.debug("nvim pid: "+ str(nvims[socket_index].call("getpid")))
       ###l.debug("nvim_win  : " + str(nvim_win))
       ###l.debug("active_win: " + str(active_win))
        if active_win == nvim_win:
            states.append(True)
            ##l.debug('focus: True')
        else:
            states.append(False)
            ##l.debug('focus: False')
    focus_of_nvim_by_socketnum_list = states
    generated_focus_of_nvim_by_socketnum_list = True   #}}} 
            
def attach_nvims(mode=0):
    """   #{{{
    attach neovim interfaces to the global sockets and set the global nvims
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values unconditionally
    """
    # var to update
    global nvims
    if mode==0 and nvims is not None:
        return
    if mode==1:
        if nvims is not None:
            if len(nvims) == len(sockets):
                 return
    gen_socketlist_of_nvims(mode=0)
    nvims=[]
    try:
        for i in range(0,len(sockets)):
            ##l.debug("attach nvim: "+ sockets[i])
            nvims.append(neovim.attach('socket',path=sockets[i]))
    except FileNotFoundError:
        # Failed prob because of outdated socketfile
        # so need to update socketfile.
        scan_for_sockets()   #}}} 

def gen_socketlist_of_nvims(mode=0):
    """   #{{{
    if unset ,sets the global sockets list
    modes are: 0 initial generation, do nothing if run again
               1 try determine if update is needed and update in case
               2 update all values unconditionally
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
                v('need to load or scan sockets: '+envsock)
                load_or_scan_sockets()
    gen_socketlist_of_nvims=True   #}}} 
                
def decide_witch_nvim_sock_to_use_for_edit():
    global socket_index_to_connect   #{{{
    socket_index_to_connect=0
    
    # need some sockets
    gen_socketlist_of_nvims(mode=0)
    
    # default fallback
    global open_other_monitor
    open_other_monitor=False
    print("sockets",sockets)
    # decide
    if len(sockets)==1:
        return
    else:
        # more than one sock, so need proper scan
        gen_focus_of_nvim_by_socketnum_list(mode=1)
        gen_incomplete_monitor_positions_list(mode=1)
        ##l.debug('socket: '+str(args.select_socket))
        done=False
        if args.select_socket==0:
            # want to connect to current monitor nvim
            ##l.debug('want to connect to curren monitors nvim')
            for i in range(len(sockets)):
                if focus_of_nvim_by_socketnum_list[i]:
                    socket_index_to_connect = i
                    open_other_monitor=False
                    return
        elif args.select_socket >= 1:
            # want to connect to other monitor nvim, so skip same monitor and own socket
            ##l.debug('want to connect to other monitors nvim')
            pos_of_focused_nvim=None
            # get pos of the focused window
            for i in range(len(sockets)):
                if focus_of_nvim_by_socketnum_list[i]:
                     pos_of_focused_nvim = pos_of_nvim_by_sock[i]
            for j in range(1,args.select_socket+1):
                for i in range(len(sockets)):
                           # not my window                          # not same monitor                           # and count sockets
                    if not focus_of_nvim_by_socketnum_list[i] and not pos_of_focused_nvim == pos_of_nvim_by_sock[i] and j == args.select_socket:
                         socket_index_to_connect=i
                         open_other_monitor=True
                         return
            # if not found a window that is on the other monitor...
            # choose the next counter other ones
            if not done:
                ##l.debug('not found on other')
                for j in range(1,args.select_socket+1):
                    for i in range(len(sockets)):
                        if not focus_of_nvim_by_socketnum_list[i] and j == args.select_socket:
                             socket_index_to_connect=i
                             open_other_monitor=False
                             return
        else:
            # want to connect to current monitor nvim
            done=False
            for i in len(sockets):
                if focus_of_nvim_by_socketnum_list[i]:
                    socket_index_to_connect = i
                    open_other_monitor = False
                    return   #}}} 

def v(msg, **kwargs):
    if args.verbose:   #{{{
        print(msg, **kwargs)   #}}} 

def scan_for_sockets():
    global xdotool_utils   #{{{
    from pylib.xutils import xdotool_utils
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
    v('found sockets:')
    socketfile=get_socketfilename()
    f=open(socketfile,mode='wt')
    for socket in sockets:
         v(str(socket))
         f.write(socket)
         f.write('\n')
    f.close()
    have_sockets = True   #}}} 
    
def get_socketfilename():
    global socketfile   #{{{
    if socketfile is None:
        socketfile= socketfilebase + "_" + get_hostname()
    return socketfile   #}}} 

def load_or_scan_sockets():
    global sockets   #{{{
    sockets=[]
    socketfile=get_socketfilename()
    if exists(socketfile):
        ##l.debug("useing socketfile")
        f=open(socketfile,mode='rt')
        for line in f.readlines():
            sockets.append(line.strip())
    else:
        ##l.debug("no socketfile")
        scan_for_sockets()
    ##l.debug(sockets)   #}}} 

def remote():
    bn=basename(sockets[0])   #{{{
    if bn[0:18]=="nvim_forward_from_":
        return True   #}}} 

def get_remote_hostname():
    a=basename(sockets[0])[18:]   #{{{
    pos=a.find('_')
    hostname=a[:pos]
    print(hostname)
    if len(hostname)==0:
        raise Exception("error1")
    return hostname    #}}} 
    
def makedir(path):
    """   #{{{
    Makes a dir if needed for the file addressed with path.
    If the path is already a dir, nothing happens. 
    """
    thing=abspath(path)
    thing=split(abspath(path))[0] # assuming thing is always a a dir or not existing
    if not exists(thing):
        mkdir(thing)   #}}} 

def autowait(first_file_arg):
    # don't wait for pass prog. It don't like it, or so.   #{{{
    if (not first_file_arg.find("pass") is -1) and (not first_file_arg.find("shm") is -1):
        wait()   #}}} 

def wait():
    from sys import stdin   #{{{
    from tty import setcbreak,tcsetattr,TCSADRAIN,tcgetattr
    old=tcgetattr(stdin)
    setcbreak(stdin)
    print(waitmsg)
    a=stdin.read(1)
    tcsetattr(stdin, TCSADRAIN, old)   #}}} 
    
def gen_target_desktop():
    """   #{{{
    target desktop like wmctrl understands desktops
    """
    # use nvim to run cmd because its already running and has display vars, etc. set
    try:
        outp=nvims[ socket_index_to_connect ].call( 'system' ,'wmctrl -l' )
        outp_lines = outp.splitlines()
        for line in outp_lines:
            hex_string= hex(int(target_window))
            while len(hex_string) < 10:
                hex_string = hex_string[0:2]+'0'+hex_string[2:]
            f = line.find( hex_string )
            if f is not -1:
                ##l.debug("found line: "+line)
                target_desktop = line.split()[1]
    except KeyboardInterrupt: raise
    except: target_desktop = str(None)
    return target_desktop   #}}} 
            
def nvim_open_file(file):
    makedir(file)   #{{{
    if isdir(file) and args.select_socket == 0 and not args.new_tab:
        pass
    else:
        nvims[ socket_index_to_connect ].call('EventWinLeave')
        nvims[socket_index_to_connect].command('tabnew')
    if not remote(): 
        nvims[socket_index_to_connect].command( 'e '+abspath(file) )
    else:
        hostname=get_hostname()
        remotehost=get_remote_hostname()
        path_on_remote='/mnt/'+hostname+abspath(file)
        nvims[socket_index_to_connect].command( 'e '+path_on_remote)
    ##l.debug(open_other_monitor)
    if open_other_monitor:
        ##l.debug( pos_of_nvim_by_sock )
        if pos_of_nvim_by_sock[ socket_index_to_connect ] == 'r':
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+f')
        elif pos_of_nvim_by_sock[ socket_index_to_connect ] == 'l':
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+s')
        else:
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+f')   #}}} 

def nvim_run_command(command):
    if args.select_socket == 0 and not args.new_tab:   #{{{
        pass
    else:
        nvims[ socket_index_to_connect ].call('EventWinLeave')
        nvims[socket_index_to_connect].command('tabnew')

    nvims[socket_index_to_connect].command( command )

    if open_other_monitor:
        if pos_of_nvim_by_sock[ socket_index_to_connect ] == 'r':
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+f')
        elif pos_of_nvim_by_sock[ socket_index_to_connect ] == 'l':
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+s')
        else:
            nvims[socket_index_to_connect].call('system','xdotool key --clearmodifiers ctrl+alt+f')   #}}} 

def list_to_elementLenList(l):
    ll=[]   #{{{
    for i in l:
        ll.append(len(i))
    return ll   #}}} 

def gen_target_window_id():
    global target_window   #{{{
    try:
        target_window = int(nvims[socket_index_to_connect].call( 'system' , 'echo $WINDOWID' ))
    except ValueError:
        target_window = None   #}}} 

def remember_home_and_to_go_back_there():
    if len(args.files) == 1:   #{{{
        # store winid of inside nvim
        global nvim_win_id
        nvim_win_id = nvims[ socket_index_to_connect ].call( 'win_getid' )
        # remember want to get back
        global back
        back=True
    else:
        l.error("winback works only with single file")   #}}} 

def setup_way_back():
    ##l.debug("setup go back stuff")   #{{{
    nvims[socket_index_to_connect].command( "augroup winback")  #start group
    nvims[socket_index_to_connect].command( "au! winback")  #delete the aucmds
    if not open_other_monitor:
          nvims[socket_index_to_connect].command( "au BufUnload <buffer> call win_gotoid("+str(nvim_win_id)+")" )  # finally assign the buffer local autocmd to the group
    elif open_other_monitor:
          nvims[socket_index_to_connect].command( "au BufUnload <buffer> call system('xdotool key --clearmodifiers ctrl+alt+f')")
    nvims[socket_index_to_connect].command( "augroup end")                  # end group so can be deleted   #}}} 

def enable_debug():
    l.setLevel( DEBUG )   #{{{
    for i in l.handlers:
        i.setLevel( DEBUG )
    l.debug( 'debugging enabled' )   #}}} 
    
def table(header,columns):
    from columnize import columnize as col   #{{{
    print_list=[]
    headerwidth=0
    for i in range(len(columns)):
        headerwidth = headerwidth + max(list_to_elementLenList(header[i]))
        print_list.extend(header[i])
        print_list.extend(columns[i])
    colsep=' | '
    col_opts = \
    {'arrange_array': False,
     'arrange_vertical': True,
     'array_prefix': '',
     'array_suffix': '',
     'colfmt': None ,
     'colsep': colsep,
     'displaywidth': headerwidth + 2 + ( len(header) -1 ) * len(colsep),
     'lineprefix': '',
     'linesuffix': '\n',
     'ljust': None,
     'term_adjust': False}
    ##l.debug(col_opts[ 'displaywidth'])
    return col(print_list, opts=col_opts)    #}}} 

def do_verbose_stuff():
    gen_focus_of_nvim_by_socketnum_list()   #{{{
    gen_pos_of_nvim_by_sock_list()
    gen_pos_of_nvim_by_sock()
    d("pos-by-sock-: {}".format(pos_of_nvim_by_sock))
    gen_nvims_visible_state_by_socket()

    header = [[  'socket',
                 '-----------------'],[  'focused',
                                         '-------'],[  'visible',
                                                       '-------'],[  'pos',
                                                                     '---'  ]]
    columns = [ sockets, focus_of_nvim_by_socketnum_list, nvims_visible_state_by_socket, pos_of_nvim_by_sock ]
    print( table(header,columns))

class NvimPool():
    def __init__(self,sockets=[]):
        self.sockets=sockets

    def add(socket):
        self.sockets.append(socket)

if __name__=="__main__":
    ### main code
    args=parser.parse_args()
    # testing stuff
    #args.verbose=True
    #args.scan=True
    #def exit(*args):
    #    print('exit '+str(*args))
    ##### end testing stuff

    if args.testing:
        """
        testing stuff and exit by exception
        """
        from pprint import pprint
        for k,v in environ.items():
            print("{}={}".format(k,v))
        raise Exception('done')
    
    
    if args.debug:
        enable_debug()
    
    if args.scan:
        scan_for_sockets()
    decide_witch_nvim_sock_to_use_for_edit()
    from pylib.du import dd,d0,d1
    dd(socket_index_to_connect)
    attach_nvims()
    
    if args.verbose:
        do_verbose_stuff()
    
    if args.testing:
        """
        testing stuff and exit by exception
        """
        from pprint import pprint
        pprint(environ())
        raise Exception('done')
    
    if args.back:
        # go back phase 1
        remember_home_and_to_go_back_there()
    
    # open files
    if not isatty(stdin.fileno()):
        with open(pagerfilepath,mode="wb") as pf:
            pf.write(stdin.buffer.read())
        args.files.append(pagerfilepath)
    
    for i in args.files:
        nvim_open_file(i)
    
    if args.command:
        nvim_run_command(args.command)
            
    if back:
        # go back phase 2
        # this after all win and buffer opening , configure the way back
        setup_way_back()
    
    if args.wait:
        wait()
    elif len(args.files) > 0:
        autowait(args.files[0])
# vim: set foldmethod=indent foldlevel=0 foldnestmax=1 :

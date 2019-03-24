#!/usr/bin/python3
waitmsg='>> waiting for ANYKEY <<'
import logging as l
l.basicConfig()
def d():
    l.debug('')
from sys import argv
from sys import exit
from os import environ
from os.path import abspath,isdir,exists,split,basename,isdir
from os.path import join as pathjoin
from os import mkdir
import neovim


import argparse
parser=argparse.ArgumentParser( description="opens file in new nvim tab")
parser.add_argument("-w","--wait", action="store_true", help= "Wait until confirmationn by a keypress after opening the file/s" )
parser.add_argument("-c","--confirm-by-buffer-unload", action="store_true", help = "Wait until confirmirmation that the editing is done by checking whether the buffer is closed and furter the calling terminal buffer is in insert mode." )
parser.add_argument( "-b",'--back',action="store_true", help="instruct nvim to go back to terminal window, after buffer is closed. This only works if a single file is specified." )
parser.add_argument( "-s",'--select-socket',action="store_true", help="scan nvim sockets and select from list")
parser.add_argument('files', metavar='files', nargs='+', type=str, help='files to open')
##parser.add_argument()

def update_socket_path():
    """
    sets the global path var
    """
    global args
    global path
    if args.select_socket==True:
        sockets=scan_for_socket()
        for i in range(0,len(sockets)):
            print(str(i)+": "+sockets[i])
        inp=input("enter number to select socket:")
        path=sockets[int(inp)]
        
    else:
        path=environ['NVIM_LISTEN_ADDRESS' ]


def scan_for_sockets():
    from os import listdir
    from subprocess import getstatusoutput
    tmp=listdir("/tmp")
    dirs=[]
    for i in tmp:
        if i[:4]=="nvim":
            print(i)
            if isdir(i):
                print(i)
                cc=pathjoin("/tmp",i)
                c=listdir(cc)
                print(cc)
                for j in c:
                    if j=="0":
                        if getstatusoutput(["lsof",c])[0] == '0':
                            l.append(c)
    print(l)
                        
                        
            


def remote():
    bn=basename(path)
    if bn[0:18]=="nvim_forward_from_":
        return True

def get_remote_hostname():
    a=basename(path)[18:]
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

def nvim_open_file(file):
    makedir(file)
    if isdir(file):
        pass
    else:
        nvim.command( 'tabnew'           )
    if not remote(): 
        nvim.command( 'e '+abspath(file) )
    else:
        from platform import node
        hostname=node()
        remotehost=get_remote_hostname()
        path_on_remote='/mnt/'+hostname+abspath(file)
        nvim.command( 'e '+path_on_remote)

## main code
args=parser.parse_args()
update_socket_path()
nvim = neovim.attach('socket',path=path)

if args.back:
    if len(args.files)==1:
        d()
        win_id=nvim.call('win_getid')
        nvim_open_file(files[0])
        nvim.command( "augroup end")                  # end group so can be deleted
        nvim.command( "silent augroup! winback")      # delete group so previously defined aucmds are away
        nvim.command( "augroup winback")              # create new clean group so aucmds can be assigned to it
        nvim.command( "au winback BufUnload <buffer> call win_gotoid("+str(win_id)+") | startinsert" )  # finally assign the buffer local autocmd to the group
    else:
        l.error("winback works only with single file")
    exit()
    
for i in args.files:
   nvim_open_file(i)


if args.wait:
    wait()
else:
    autowait(args.files[0])

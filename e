#!/usr/bin/python3
import logging as l
l.basicConfig()
def d():
    l.debug('')
from sys import argv
from sys import exit
from os import environ
from os.path import abspath
import neovim
path=environ['NVIM_LISTEN_ADDRESS']
nvim = neovim.attach('socket',path=path)


import argparse
parser=argparse.ArgumentParser( description="opens file in new nvim tab")
parser.add_argument("-w","--wait", action="store_true", help= "Wait until confirmationn by a keypress after opening the file/s" )
parser.add_argument("-c","--confirm-by-buffer-unload", action="store_true", help = "Wait until confirmirmation that the editing is done by checking whether the buffer is closed and furter the calling terminal buffer is in insert mode." )
parser.add_argument( "-b",'--back',action="store_true", help="instruct nvim to go back to terminal window, after buffer is closed. This only works if a single file is specified." )
parser.add_argument('files', metavar='files', nargs='+', type=str, help='files to open')
##parser.add_argument()
args=parser.parse_args()

def nvim_open_file_in_new_tab(file):
        nvim.command( 'tabnew'           )
        nvim.command( 'e '+abspath(file) )

if args.back:
    if len(args.files)==1:
        d()
        win_id=nvim.call('win_getid')
        nvim_open_file_in_new_tab(files[0])
        nvim.command( "augroup end")                  # end group so can be deleted
        nvim.command( "silent augroup! winback")      # delete group so previously defined aucmds are away
        nvim.command( "augroup winback")              # create new clean group so aucmds can be assigned to it
        nvim.command( "au winback BufUnload <buffer> call win_gotoid("+str(win_id)+") | startinsert" )  # finally assign the buffer local autocmd to the group
    else:
        l.error("winback works only with single file")
    exit()
    
for i in args.files:
   nvim_open_file_in_new_tab(i)

if args.wait:
    input('Done with editing? Press SOME KEY TO CONFIRM')

#!/usr/bin/python3
import logging as l
from os import getcwd
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
parser=argparse.ArgumentParser( description="opens newebuild prefilled with stuff in new nvim tab")
parser.add_argument("-w","--wait", action="store_true", help= "maybe nonsens option .Wait until confirmationn by a keypress after opening the file/s" )
parser.add_argument("-c","--confirm-by-buffer-unload", action="store_true", help = "maybe nonsens option .Wait until confirmirmation that the editing is done by checking whether the buffer is closed and furter the calling terminal buffer is in insert mode." )
parser.add_argument( "-b",'--back',action="store_true", help="maybe nonsens option .instruct nvim to go back to terminal window, after buffer is closed. This only works if a single file is specified." )
parser.add_argument('filebase', metavar='filebase', type=str, help='ebuild filename without .ebuild (will be autoadded)')
##parser.add_argument()
args=parser.parse_args()

def nvim_newebuild_in_new_tab(filebase):
        nvim.command( 'tabnew' )
        nvim.command( 'edit' + ' ' + args.filebase + '.ebuild' )
        nvim.command( 'NewEbuild' )

if args.back:
    d()
    win_id=nvim.call('win_getid')
    nvim_newebuild_in_new_tab(args.filebase)
    nvim.command( "augroup end")                  # end group so can be deleted
    nvim.command( "silent augroup! winback")      # delete group so previously defined aucmds are away
    nvim.command( "augroup winback")              # create new clean group so aucmds can be assigned to it
    nvim.command( "au winback BufUnload <buffer> call win_gotoid("+str(win_id)+") | startinsert" )  # finally assign the buffer local autocmd to the group
    exit()
    
nvim_newebuild_in_new_tab(args.filebase)

if args.wait:
    input('Done with editing? Press SOME KEY TO CONFIRM')

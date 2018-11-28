#!/usr/bin/python3
from sys import argv
from sys import exit
from os import environ
import neovim
path=environ['NVIM_LISTEN_ADDRESS']
nvim = neovim.attach('socket',path=path)


def exit_interpret_retcode(r):
    """
    """
    if r < 1:
        exit(1)
    else:
        exit(0)

def exit_if_failed(r,funcname):
    if r < 1:
        exit_interpret_retcode(r)

def nvim_run_cmdline_in_new_tab(liste):
        nvim.command( 'tabnew' )
        return nvim.call( "termopen", liste )

exit_interpret_retcode(nvim_run_cmdline_in_new_tab(argv[1:]))

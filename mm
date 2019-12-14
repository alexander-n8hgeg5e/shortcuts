#!/usr/bin/python3

from subprocess import Popen,PIPE,STDOUT,check_output,call
from sys import stdin,exit,argv
from sys import exit as exit_
from os import linesep
from termios import tcgetattr,tcsetattr,TCSADRAIN
from tty import setraw
from time import sleep

cmd = ['xdotool','-']

fd = stdin.fileno()
old_settings = tcgetattr(fd)

setraw(stdin.fileno())

popens = []
for i in range(20):
    popens.append(Popen( cmd, stdin = PIPE , stdout=PIPE ))

keymap = \
{
    'e':'mousemove_relative -- 0 -10',
    'd':'mousemove_relative -- 0  10',
    's':'mousemove_relative -- -10 0',
    'f':'mousemove_relative -- 10  0',
    'E':'mousemove_relative -- 0 -50',
    'D':'mousemove_relative -- 0  50',
    'S':'mousemove_relative -- -50 0',
    'F':'mousemove_relative -- 50  0', 
    ' ':['click', '1'],
    '\x0a':['click','3'],
    '\x0d':['click','3'],
}
def sendcmd(cmd_): 
    popens[0].stdin.write(  ( cmd_ + linesep ).encode() )
    popens[0].stdin.close()
    popens.pop(0)
    popens.append(Popen( cmd, stdin = PIPE , stdout = PIPE ))
    
def exit(*args):
    tcsetattr(fd, TCSADRAIN, old_settings)
    exit_(*args)

for i in argv:
    if 'r' in  i:
        sendcmd('mousemove 50 50')
for i in argv:
    if 'q' in  i:
        exit()

done = False
while not done:
    c = stdin.read(1)
    if not c=='q':
        if c in [' ','\x0a','\x0d']:
            # need to return to current active window and wait for that
            returnwin  = check_output(['xdotool','getwindowfocus']).decode().strip()
            returndesk = str(int(check_output(['xdotool', 'get_desktop_for_window', returnwin ]).decode().strip())+1)
            call(['xdotool']+keymap[c])
            call(['xdotool','key','ctrl+alt+' + returndesk ])
            sleep(0.5)
            call(['xdotool', 'windowfocus', returnwin] )
        elif c == '\x03':
            raise KeyboardInterrupt('0x03')
        else:
            for i in range(len(popens)):
                try:
                    #print(bytes(c,'UTF-8').hex())
                    popens[i].stdin.write(  ( keymap[c]+linesep ).encode() )
                    popens[i].stdin.close()
                    popens.pop(i)
                    popens.append(Popen( cmd, stdin = PIPE , stdout = PIPE ))
                    break
                except KeyError:
                    pass
    else:
        exit()




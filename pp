#!/usr/bin/python3
from configparser import ConfigParser
from os import environ as env
from os import listdir
from subprocess import getoutput
from sys import argv

gitpushdir = env["HOME"] + '/' + '.gitpush'
target_to_push = argv[1]
pack_to_push = argv[2]

class AmbiguousError(Exception):
    def __init__(self, message, errors):
        super().__init__(message)
        self.errors=errors
class NotFoundError(Exception):
    def __init__(self, message, errors):
        super().__init__(message)
        self.errors=errors

def parse_config():
  """
  parses config,list of targets, returns list of packs and config
  """
  c=ConfigParser()
  targets = listdir(gitpushdir)
  for target in targets:
     with open(gitpushdir + '/' + target,'rt') as f:
        c.read_file(f)
  cmd_base = ['git', 'push' , target_to_push ]
  packs=list(c['packs'])
  return targets,packs,c,
  

def get_repos(pack):
   """
   return repos belong to pack
   """
   pack_get_cmd = c['packs'][pack_to_push]
   return getoutput( pack_get_cmd ).splitlines()


def target(target_to_push,targets):
  found=0
  for i in targets:
    f=i.find(target_to_push)
    if f is 0:
        #found it at start
        found=found+1
        t=i
  if found > 1:
      print(found)
      raise AmbiguousError("need more characters to distinguish the targets")
      return None
  if found == 0:
        raise NotFoundError('no target found',pack_to_push)
        return None
  return t

def pack(pack_to_push,packs):
  found=0
  for i in packs:
    f=i.find(pack_to_push)
    if f is 0:
        p=i
        #found it at start
        found=found+1
  if found > 1:
        raise AmbiguousError("need more characters to distinguish the packs",pack_to_push)
        return None
  if found is 0:
        raise NotFoundError('no pack found',pack_to_push)
        return None
  return p



targets,packs,c=parse_config()
print(targets)
target=target(target_to_push,targets)
pack  =  pack(pack_to_push,packs)
pushstring = 'push '+target+' '+ pack
print(pushstring)







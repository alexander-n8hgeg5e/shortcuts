#!/usr/bin/python3
from sys import environ
from re import match
from pprint import pformat

# argparse



# env transfer
patterns = environ["REPATS"].split(" ")
matches={}
for k in environ.keys():
    for pat in patterns:
        if match(k,pat):
            matches.update({k:environ[k]})
data = pformat(matches)


# remote
class UI_client():

    def check_server():
        pass
    




# local
class UI_server():
    
    def where_i_am(*z,**zz):
        pass

    def get_layout(*z,**zz):
        pass

# coding: utf-8
def get_host_flags(host):
    import pickle
    from pickle import Unpickler
    from subprocess import check_output
    flags=check_output(['ssh', host, 'python', '-c', '''\'from resolve_march_native import engine\nflags=engine.Engine("gcc",False)._get_march_native_flag_set();engine.Engine._resolve_mno_flags(flags)\nimport pickle\nfrom sys import stdout\npickle.Pickler(stdout.buffer.raw).dump(flags)\''''])
    return pickle.loads(flags)
    

#!/usr/bin/env python

import os
import sys
import logging
import argparse
import subprocess
import json

def GetLogger(name):
    logger = logging.getLogger(name)
    logger.setLevel(logging.DEBUG)
    fmtstr = '%(asctime)s [%(levelname)s] [%(name)s] [%(filename)s:%(lineno)d]: %(message)s'
    fmter = logging.Formatter(fmtstr)
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(fmter)
    logger.addHandler(handler)
    return logger

def RunCmd(cmd, cwd=None, env=None, logger=None):
    if logger is not None:
        logger.info('cmd: %s, cd: %s, env: %s' % (cmd, cwd, env))

    proc = subprocess.Popen(
            cmd,
            stdout = subprocess.PIPE,
            stderr = subprocess.PIPE,
            cwd = cwd,
            env = env,
            shell=True,
            executable='/bin/bash'
            )
    stdout, stderr = proc.communicate()
    status = proc.wait()
    return status, stdout, stderr

def GetArgs():
    parser = argparse.ArgumentParser(description='')
    parser.add_argument('-s', '--settings', default='settings.json', help='settings file')
    return parser.parse_args()

if __name__ == '__main__':
    logger = GetLogger('main')
    args = GetArgs()
    logger.info(args)

    with open(args.settings, 'r') as fin:
        settings = json.load(fin)

    for server in settings['lsp']['servers'].keys():
        dir = os.path.join(os.path.expanduser(settings['lsp']['root']), server)
        if os.path.exists(dir):
            if os.path.exists(os.path.join(dir, 'installed')):
                logger.info('lsp server: %s had installed' % (server))
                continue
            else:
                logger.warn('lsp server: %s install dir exist, but not installed, will reinstall' % (server))
                os.removedirs(dir)
        logger.info('lsp server: %s installing in %s' % (server, dir))
        os.makedirs(dir)
        if 'install' in settings['lsp']['servers'][server].keys() and len(settings['lsp']['servers'][server]['install']) > 0:
            for cmd in settings['lsp']['servers'][server]['install']:
                status, stdout, stderr = RunCmd(
                        cmd['cmd'],
                        cwd=os.path.join(dir, cmd['workspace']),
                        logger=logger
                        )
                if status != 0:
                    logger.error('run cmd: %s fail, stdout: %s stderr: %s' % (cmd, stdout, stderr))
                    exit(1)
        with open(os.path.join(dir, 'installed'), 'w') as fout:
            fout.write('installed')
        logger.info('lsp server: %s installed' % (server))

    exit(0)

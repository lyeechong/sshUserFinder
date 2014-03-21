#!/usr/bin/python
import paramiko, getpass
CSHOSTS_FILENAME = 'cshosts.dat'
COMMAND = 'ls' 

DEBUG = True

USERNAME = raw_input('Username: ')
PASSWORD = getpass.getpass()
PORT = 22

def ssh(hostname):
    if(DEBUG):
        print 'in ssh function, trying', hostname
    try:
        full_hostname = hostname + '.cs.utexas.edu'
        print 'full hostname: ', full_hostname
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(full_hostname, port=PORT, username=USERNAME, password=PASSWORD)
         
        stdin, stdout, stderr = client.exec_command(COMMAND)
        print stdout.read(),
    except Exception as inst:
        if(DEBUG):
            print "ERROR: ", inst.args
    finally:
        client.close()
    print ""
    
def run():
    hostnames = open(CSHOSTS_FILENAME).read().splitlines()
    for hostname in hostnames:
        print 'trying', hostname
        ssh(hostname)

run()

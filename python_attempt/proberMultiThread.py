#!/usr/bin/python
import paramiko, getpass
from multiprocessing.pool import ThreadPool
CSHOSTS_FILENAME = 'cshosts.dat'
COMMAND = 'who' 


DEBUG = False
USERNAME = raw_input('Username: ')
PASSWORD = getpass.getpass()
PORT = 22

VICTIM = raw_input('Victim: ')

def checkOutput(output):
    if VICTIM in output:
        print 'victory'
        return True
    return False

def ssh(hostname):
    found = False
    
    if(DEBUG):
        print 'in ssh function, trying', hostname
    try:
        full_hostname = hostname + '.cs.utexas.edu'
        if DEBUG:
            print 'full hostname: ', full_hostname
            
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.connect(full_hostname, port=PORT, username=USERNAME, password=PASSWORD)
        stdin, stdout, stderr = client.exec_command(COMMAND)
        
        output = stdout.read()
        if(DEBUG):
            print output
        found = checkOutput(output)
        
    except Exception as inst:
        if(DEBUG):
            print "ERROR at ", hostname, ": ", inst.args
            
    finally:
        client.close()
        
    if found and DEBUG:
        print "in ssh function, found victim at", hostname
    return found
    
    
def run():
    hostnames = open(CSHOSTS_FILENAME).read().splitlines()
    found = False
    pool = ThreadPool(processes=195)
    results = {}
    print ""
    for hostname in hostnames:
        print 'trying', hostname
        results[hostname] = pool.apply_async(ssh, (hostname, )) #async'ly try that host
    for hostname in hostnames:
        res = results[hostname].get(timeout=10) #timeout of 10 seconds
        if res:
            print 'found ', VICTIM, ' at ', hostname
            found = True
    if not found:
      print VICTIM, ' was not found on any of the CS hosts'
        
run()

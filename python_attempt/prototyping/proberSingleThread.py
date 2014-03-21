#!/usr/bin/python
import paramiko, getpass
CSHOSTS_FILENAME = 'cshosts.dat'
COMMAND = 'who' 

DEBUG = True

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
    print ""
    return found
    
    
def run():
    hostnames = open(CSHOSTS_FILENAME).read().splitlines()
    found = False
    for hostname in hostnames:
        print 'trying', hostname
        found = ssh(hostname)
        if found:
            print 'found victim at', hostname
            break
    if not found:
        print 'victim was not found'
     
        
run()

#!/usr/bin/python
import paramiko, getpass
CSHOSTS_FILENAME = 'cshosts.dat'
COMMAND = 'ls' 

class sshLoop(object):

    #USERNAME = raw_input('Username: ')
    #PASSWORD = getpass.getpass()
    PORT = 22

    def run():
        hostnames = open(CSHOSTS_FILENAME).read().splitlines()
        for hostname in hostnames:
            print 'trying', hostname

    def ssh(hostname):
        try:
            client = paramiko.SSHClient()
            client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            client.connect(hostname, port=PORT, username=USERNAME, password=PASSWORD)
             
            stdin, stdout, stderr = client.exec_command(command)
            print stdout.read(),
             
        finally:
            client.close()
            

    run()


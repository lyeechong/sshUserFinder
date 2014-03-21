#!/usr/bin/python
 
import paramiko, getpass

username = raw_input('Username: ')
password = getpass.getpass()

hostname = 'pride.cs.utexas.edu'
command = 'ls' 
port = 22
 
try:
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    client.connect(hostname, port=port, username=username, password=password)
     
    stdin, stdout, stderr = client.exec_command(command)
    print stdout.read(),
     
finally:
    client.close()

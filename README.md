#SSH User Finder
SSHes into each of the CS machines and checks to see who is on the computer.
The python version works. The Perl version is missing a Math library to run on the CS machines.

Usage:
```
python python_attempt/proberMultiThread.py
```

Username: [your CS username]

Password: [your CS password]

Victim: [the CS username of the person you're trying to find]

If you don't know the CS username of the victim, you can always try
```
finger [guess]@cs.utexas.edu
```
Where guess is what you think their username may contain.
Eg:
```
finger kevin@cs.utexas.edu
```
Will give you a bunch of results.

You can also try looking into the LDAP if you know their EID.

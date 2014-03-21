#!/usr/bin/perl

#use lib "~/perl5/lib";

use strict;
use Net::SSH::Perl; # -- how else will we get our victims?
use Try::Tiny; # -- try catches!
use threads qw[ yield ];
use threads::shared;

# -- output printline options:
my $debugSSH = 1; #if 1, more SSH output will be printed
my $debugGeneral = 1; #if 1, general stuff going on will be printed
my $silent = 0; #if 1, no output produced until the result

if($silent)
{
  # -- shhh.
  $debugGeneral = 0;
  $debugSSH = 0;  
}
else
{
  # -- not enabling warnings stops the exiting subroutine messages
  use warnings;
}

# -- spinner thread vars init
my $ready : shared = 0;
my $isOk : shared  = 0;

# -- ask the user for keyboard input of the victim
print "Hehehe. Who are you searching for? :: ";
my $keyboardInput = <STDIN>;
chomp($keyboardInput);

# -- start the timer...
my $startTime = time;

my $victim = $keyboardInput;
print "Let's go raid the CS machines in search of ", $victim, "\n";

# -- open the login data file
my $filename = 'loginData.dat';
open(my $fh, $filename) or die "Could not open the file '$filename' $!";

# -- init stuff
my $linecount = 0;
my $username = 'DEFAULT';
my $hostname : shared = 'DEFAULT';
my $password = 'DEFAULT';
my $ssh;

# -- spinner thread stuff
async 
{
  local $| = 1; # -- autoflush the buffer
  while ( !$ready ) 
  {
    do 
    {
      select undef, undef, undef, 0.2;
      my $formattedHostName = sprintf('%-25s', $hostname);
      printf "\r[$_] Searching: $formattedHostName" if ($isOk); # -- only spin if it's ok
    }
    for qw[ / - \ | ];
  }
  print "\rReady";
  $ready = 0;
}
->detach;

# -- okay, time to being the ssh'ing!
HOSTLOOP: while(my $line = <$fh>)
{
  $isOk = 1;
	chomp $line;
	if($linecount == 0)
	{	
		# -- username
		$username = $line;
	}
	elsif($linecount == 1)
	{
    # -- password
		$password = $line;
	}
	else
	{
	  # -- check to see if it is a blank line
		if(defined $line and $line ne "" and length $line gt 0)
		{
		  
		}
		else
		{
		  # -- skip the blank link in the file
		  if($debugGeneral)
		  {
		    print "Note: skipping a blank line in the file.\n";
		  }
		}
	
	  # -- other lines: hostnames
    $hostname = $line;	
	
	  # -- sanity checks before attempting to connect
    if($hostname eq 'DEFAULT' or
       $username eq 'DEFAULT' or
       $password eq 'DEFAULT')
    {
	    die "The textfile read the user/pass/host incorrectly! $!\n";
    }
    
    if($debugGeneral)
    {
      print "Username :: ", $username, "\n";
    }
		
		if($debugGeneral)
		{
      print "Passed sanity checks:\n";
      print "Checking hostname: ", $hostname, "\n";
      print "Attempting to connect to the host...\n";
    }
    
    
    # -- wrap around so it times out after 4 seconds
    my $TIMEOUT_CONNECTION = 4;
    eval 
    {
      local $SIG{ALRM} = sub { die "" };
      alarm($TIMEOUT_CONNECTION);
      # -- do the SSH stuff that might timeout.
      
      try
      {		
		    $ssh = Net::SSH::Perl->new(
					$hostname . ".cs.utexas.edu",
					protocol => '2,1',
            debug    => $debugSSH, # -- toggle to 1 for debug, otherwise 0 for silent
        );
      }
      catch
      {
        if($debugGeneral)
				{
					print "Connection to ", $hostname, " failed due to ", $_,", skipping that host...\n";
        }
        next HOSTLOOP;
      };
      
      if($debugGeneral)
		  {
        print "Connected to the host, now trying to authenticate.\n";
      }
      
      try
      {
        my $TIMEOUT_LOGIN = 1;
        eval 
        {
          local $SIG{ALRM} = sub { die "" };
          alarm($TIMEOUT_LOGIN);
          
          # -- attempt to login... and it may timeout!
          $ssh->login( $username, $password );
          
          alarm(0);
        };
        if($@)
        {
          # -- timed out!
          if($debugGeneral)
		      {
            print "Login was too slow! ", $_," Skipping this host...\n";
          }
          next HOSTLOOP;
        }
        
      }
      catch
      {
        if($debugGeneral)
		    {
          print "Connection to ", $hostname, " failed due to ", $_,", skipping that host...\n";
        }
        next HOSTLOOP;
      };
      alarm(0);
    };
    if($@)
    {
      # -- the operation timed out :(
      # -- skip this host...
      if($debugGeneral)
		  {
        warn "Connection to ", $hostname, " failed for ", $_," (probably timed out), skipping that host...\n";
      }
      next HOSTLOOP;
    }
    else
    {
      # -- else, connection successfully made!
      if($debugGeneral)
		  {
        print "Logged in to the host successfully.\n";
      }
      # -- time to check that host for the victim...
      &runCommandOnHost();
    }
	}
	$linecount++;
	$isOk = 0;
}

print "\n\nWe searched all the hosts... no trace of the victim was found.\n";

$isOk = 0;

$ready = 1;
yield while $ready;

# -- end code execution flow


# -- subroutines defined below

sub runCommandOnHost
{
    my $cmd = "who\n";
    if($debugGeneral)
    {
      print "Running command: ", $cmd, "\n";
    }
    my ( $stdout, $stderr, $exit ) = $ssh->cmd($cmd);
    
    if(defined $stdout)
    {
      #print "stdout :: \n", $stdout, "\n";
      
      # -- a little more error checking...
      if(length $stdout gt 0)
      {
        my $success = &checkForMatchingUsername($stdout);
        if($success eq 439)
        {
          # -- GOT THE VICTIM!
        
          # -- stop the timer
          my $duration = time - $startTime;
          
          # -- time to redecorate and hang the MISSION ACCOMPLISHED! banner.
          print "\n\n";
          print " |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|\n";
          print " | * * * * * * * * *  :::::::::::::::::::::::::|\n";
          print " |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|\n";
          print " | * * * * * * * * *  :::::::::::::::::::::::::|\n";
          print " |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|\n";
          print " | * * * * * * * * *  ::::::::::::::::::::;::::|\n";
          print " |* * * * * * * * * * OOOOOOOOOOOOOOOOOOOOOOOOO|\n";
          print " |:::::::::::::::::::::::::::::::::::::::::::::|\n";
          print " |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|\n";
          print " |:::::::::::::::::::::::::::::::::::::::::::::|\n";
          print " |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|\n";
          print " |:::::::::::::::::::::::::::::::::::::::::::::|\n";
          print " |OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO|\n";
          print " |                                              \n";
          print " |                                              \n";
          print " |                                              \n";
          print " |                                              \n";
          print " |                                              \n";
          print " |                                              \n";
          print " |                                              \n";
          print " |                                              \n";
          print " |                                              \n";
          print " #############################################################################\n";
          print " #############################################################################\n";
          print " #   #####   ##   ##      ##      ##      ##   ###  ##########################\n";
          print " #     #     #######  ######  ######  ##  ##    ##  ##########################\n";
          print " #  ##   ##  ##   ##      ##      ##  ##  ##  #  #  ##########################\n";
          print " #  ### ###  ##   ######  ######  ##  ##  ##  ##    ##########################\n";
          print " #  #######  ##   ##      ##      ##      ##  ###   ##########################\n";
          print " #############################################################################\n";
          print " ####   ####    ##    ##      #  #####  #    ## ### #      ## ## #    #   ####\n";
          print " ###  #  ###  ####  ####  ##  #    #    #  #  # #####  ###### ## # #### ##  ##\n";
          print " ##  ###  ##  ####  ####  ##  # ##   ## #     # ### #      ##    #   ## ##  ##\n";
          print " #         #  ####  ####  ##  # ### ### #  #### ### #####  ## ## # #### ## ###\n";
          print " #  #####  #    ##    ##      # ####### #  ####   # #      ## ## #    #   ####\n";
          print " #############################################################################\n";
          print " #############################################################################\n";
          print "\n";
          print "Victory is ours men!\n";
          print "Hostname victim was located at: ", $hostname, "\n";
          print "Execution time: $duration seconds\n";
          die "Exiting program.\n";
        }
        elsif($success eq 404)
        {
          # -- the victim was not found... keep looking
        }
        else
        {
          # -- something went horribly wrong
          die "Something went horribly wrong and an invalid code was
            returned from the checker\n";
        }

      }
    }
    else
    {
      #print "stdout... got nothing back.\n";
    }
    if(defined $stderr)
    {
      #print "stderr :: \n", $stderr, "\n";
    }
    else
    {
      #print "stderr... got nothing back.\n";
    }
    if(defined $exit)
    {
      #print "exit   :: ", $exit, "\n";
    }
    else
    {
      #print "exit... got nothing back\n";
    }
}

sub checkForMatchingUsername
{
    my $raw = $_[0];
    
    if(not defined $raw or length $raw le 0)
    {
      die("DIE DIE DIE bad input to checking for matching username\n");
    }
    
    my @inputLines = split " ", $raw;
    
    foreach(@inputLines)
    {
      my $stringToCheck = $_;
      
      if( $stringToCheck eq $victim)
      {
        return 439;
      }
    }
    return 404;   
}

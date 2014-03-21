#!/usr/bin/perl

use strict;
use warnings;
use Net::SSH::Perl;
use Try::Tiny;

my $filename = 'loginData.dat';

open(my $fh, $filename) or die "Could not open the file '$filename' $!";

my $linecount = 0;
my $username = 'DEFAULT';
my $hostname = 'DEFAULT';
my $password = 'DEFAULT';
my $ssh;

while(my $line = <$fh>)
{
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
		  print "Note: skipping a blank line in the file.\n";
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

    print "Passed sanity checks:\n";
    print "Checking hostname: ", $hostname, "\n";
    print "Attempting to connect to the host...\n";
    
    try
    {		
		  $ssh = Net::SSH::Perl->new(
          $hostname . ".cs.utexas.edu",
          protocol => '2,1',
          debug    => 1,
      );
    }
    catch
    {
      warn "Connection to ", $hostname, " failed, skipping that host...\n";
      next;
    };
    
    print "Connected to the host, now trying to authenticate.\n";
    
    try
    {
      $ssh->login( $username, $password );
    }
    catch
    {
      warn "Connection to ", $hostname, " failed, skipping that host...\n";
      next;
    };
    
    print "Logged in to the host successfully.\n";    	

    &runCommandOnHost();

	}
	$linecount++;
}

sub runCommandOnHost
{
    my $cmd = "who\n";
    
    print "Running command: ", $cmd, "\n";
    
    my ( $stdout, $stderr, $exit ) = $ssh->cmd($cmd);
    
    if(defined $stdout)
    {
      print "stdout :: \n", $stdout, "\n";
    }
    else
    {
      print "stdout... got nothing back.\n";
    }
    if(defined $stderr)
    {
      print "stderr :: \n", $stderr, "\n";
    }
    else
    {
      print "stderr... got nothing back.\n";
    }
    if(defined $exit)
    {
      print "exit   :: ", $exit, "\n";
    }
    else
    {
      print "exit... got nothing back\n";
    }
}

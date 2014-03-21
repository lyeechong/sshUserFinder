#!/usr/bin/perl

use strict;
use warnings;
use Net::SSH::Perl;

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
		# -- hostname
		$hostname = $line;
	}
	elsif($linecount == 2)
	{
		$password = $line;
    
    # -- sanity checks
    if($hostname eq 'DEFAULT' or $username eq 'DEFAULT' or $password eq 'DEFAULT')
    {
	    die "The textfile read the user/pass/host incorrectly! $!\n";
    }

    print "Passed sanity checks:\n";
    print "\tHostname is: ", $hostname, "\n";
    print "\tUsername is: ", $username, "\n";
    print "\tPassword is: ", $password, "\n";
    print "Attempting to connect to the host...\n";
    		
		$ssh = Net::SSH::Perl->new(
        $hostname,
        protocol => '2,1',
        debug    => 1,
    );
    
    print "Connected to the host, now trying to authenticate.\n";
    
    $ssh->login( $username, $password );
    
    print "Logged in to the host successfully.\n";
	}
	else
	{
		# -- other lines: commands to execute
		if(not defined $line)
		{
		  die "Something went wrong in the code; line is not defined for some reason."
		}
		elsif($line ne "" and length $line gt 0)
		{
		  &runCommand($line);
		}
		else
		{
		  print "Skipping a blank line in the file.\n";
		}
	}
	$linecount++;
}

sub runCommand
{
    my $cmd = @_[0], "\n";
    
    print "Running command: ", $cmd, "\n";
    
    sleep(1);
    
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

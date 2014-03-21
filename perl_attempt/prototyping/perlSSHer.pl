#!/usr/bin/perl

use strict;
use warnings;
use Net::SSH::Perl;

connectToServer();

sub connectToServer {

    my $host     = 'hostname';
    my $username = 'username';
    my $password = 'password';
    my $cmd      = 'chkconfig --list';

    my $ssh = Net::SSH::Perl->new(
        $host,
        protocol => '2,1',
        debug    => 1,
    );
    $ssh->login( $username, $password );

    my ( $stdout, $stderr, $exit ) = $ssh->cmd($cmd);
    print $stdout, "\n";
}

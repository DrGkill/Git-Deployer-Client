#!/usr/bin/perl

###############################################################################
# Script Name:	Git Deployer Client
# Author: 	Guillaume Seigneuret
# Date: 	04.01.2012
# Last mod	04.01.2012
# Version:	1.0b
# 
# Usage:	gdc <projet> <branch>
# 
# Usage domain: To be executed by git hook (post-update script) 
# 
# Args :	Project name AND Branch name are mandatory if the environmental
# 		variable SSH_ORIGINAL_COMMAND is not set.	
#
# Config: 	Every parameters must be described in the config file
# 
# Config file:	Must be the name of the script (with .config or rc extension), 
# 		located in /etc or the same path as the script
# 
#   Copyright (C) 2012 Guillaume Seigneuret (Omega Cube)
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU General Public License as published by
#   the Free Software Foundation, either version 3 of the License.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU General Public License for more details.
#
#   You should have received a copy of the GNU General Public License
#   along with this program.  If not, see <http://www.gnu.org/licenses/>		 
###############################################################################

use strict;
use warnings;
use IO::Socket;
use Config::Auto;

$| =1;

{
	my $config = Config::Auto::parse();

	die("Please, provide the project name and the branch as argument\n") 
		if ( (not defined($ARGV[0]) or not defined $ENV{SSH_ORIGINAL_COMMAND}) 
			and not defined($ARGV[1]) );

	my $project_name = $ARGV[0] if defined $ARGV[0];
	my $project_name = $1 if $ENV{SSH_ORIGINAL_COMMAND} =~ /'(.*)'/;
	my $project = $1 if $project_name =~ /\/(.*).git/;
	my $branch = $ARGV[1];

	$branch = $1 if $branch =~ /\/(.*)$/;

	die "Project : $project not configured\n" if not defined($config->{$project});

	my $address 	= trim($config->{$project}->{address});
	my $port	= trim($config->{$project}->{port});

	con_and_command($address, $port,"Project: $project_name Branch: $branch");

}



sub con_and_command {
	my ($address, $port, $string) = @_;

	my $socket = IO::Socket::INET->new(Proto    => "tcp",
	                                   PeerAddr => $address,
	                                   PeerPort => $port)
	or die "Failed : $@\n";
	
	#print "*** Debut de connexion ***\n";

	while(my $reponse=<$socket>){
		print $socket $string."\r\n";
		print $socket "quit\r\n";
		print $reponse;
	}
	#print "*** Fin de connexion ***\n";
	close($socket);
}

sub trim
{
    my @out = @_;
    for (@out)
    {
        s/^\s+//;
        s/\s+$//;
    }
    return wantarray ? @out : $out[0];
}
__END__


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
use Data::Dumper;

$| =1;

{
	my $config = Config::Auto::parse();

	#print Dumper($config);

	die("Please, provide the project name and the branch as argument\n") 
		if ( (not defined($ARGV[1]) or not defined $ENV{SSH_ORIGINAL_COMMAND}) 
			and not defined($ARGV[0]) );

	my $project_name = "";
	my $project = "";
	$project_name = $ARGV[1] if defined $ARGV[1];
	$project_name = "$1.git" if defined($ENV{SSH_ORIGINAL_COMMAND}) and $ENV{SSH_ORIGINAL_COMMAND} =~ /git-receive-pack '(.*)'/;
	$project_name = $1 if defined($ENV{SSH_ORIGINAL_COMMAND}) and $ENV{SSH_ORIGINAL_COMMAND} =~ /'(.*\.git)/;
	$project = $1 if $project_name =~ /.*\/(.*)\.git/;
	$project = $1 if $project_name =~ /(.*)\.git/ and $project eq "";
	chomp(my $branch = $ARGV[0]);

	$branch = $1 if $branch =~ /\/(\w+)$/;

	print "Project : $project/$branch not configured\n" if not defined($config->{"$project/$branch"});
	die "Project : $project/$branch not configured\n" if not defined($config->{"$project/$branch"});

	my @addresses 	= split(";", trim($config->{"$project/$branch"}->{address}));

	con_and_command($_, "Project: $project_name Branch: $branch") foreach (@addresses);

}



sub con_and_command {
	my ($address, $string) = @_;

	

	my $socket = IO::Socket::INET->new(Proto    => "tcp",
	                                   PeerAddr => $address,
	                                  )
	or die "Connexion to $address failed : $@\n";
	
	#print "*** Debut de connexion ***\n";

	while(my $reponse=<$socket>){
		print $reponse;
		
		if($reponse =~ /please make your request/){
			print $socket $string."\r\n";
		}

		#print $socket "quit\n\r";	
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


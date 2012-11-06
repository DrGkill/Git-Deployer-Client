Git-Deployer-Client - A client for interacting with the Git-Deployer-Server (GDS)
==================================================================================

Table of Contents:
------------------

* [Introduction] (#intro)
* [Install] (#install)


<a name="intro"></a>
### Introduction
Git Deployer Client is a script who trigger an update by contacting the GDS (Git Deployer Server).
It simply hat to be put in a bare repository git hook.  
So it works well with all central git management tool such as : Gitolite, Gitlab, Gitorious, etc.

<a name="install"></a>
### Install and Config
The project needs sevral Perl plugins to work properly:

* IO::Socket (installed by default on main systems)
* Data::Dumper (installed by default on main systems)
* Config::Auto

To install them : 


```
$ perl -MCPAN -e shell
> install Config::Auto
> install IO::Socket
> install Data::Dumper
```

or for Debian :

```
$ apt-get install libconfig-auto-perl
```

Clone the project into your favorite directory :
```
$ git clone https://github.com/DrGkill/Git-Deployer-Client.git
```

Place the script call into your project Hook:

```
$ vim /path/to/my/project_bare_repository/hooks/post-update

#!/bin/sh
#
# An example hook script to prepare a packed repository for use over
# dumb transports.
#
# To enable this hook, rename this file to "post-update".

/path/to/git-deployer-client/GDC.pl $1

exec git update-server-info

```


Finally, configure your projects by editing the main configuration file :

Begin lines by '#' to make comments

```
$ cp GDC.config.sample GDC.config
$ vim GDC.config
# Imagine a Gitorious project named test/test.git, just record the conf
# with test
[test/mybranch]
	# If the project has to be loaded onto multiple servers
	address = 192.168.0.1:32337;127.0.0.1:32337;192.168.0.6:8888

[test/master]
	address = my.testprod.com:32337


[toto/master]
	address = 192.168.10.25:32337

[end]
```


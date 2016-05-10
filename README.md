# webofmars MySQL tools

A small collection of handy tools in DBA life

## mysql-replicaction-check

Simple script to check that a MySQL replication is running as expected and send an email alert if not.
Use mysql client in order to retrieve infos (via a 'SHOW SLAVE STATUS').

This is very simple compaired to percona tools or others but don't have dependecies and is platform agnostic.

NB: This must be run from the slave server.

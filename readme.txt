
ConfluenceToTWiki Converter
=============================

How To?

Migrating from Confluence Web to TWiki can be achieved in following 2 steps-

1.Editing configuration files
 - ConfluenceConfig.conf
 - ConvertorConfig.conf
2.Executing command line utility genTWikiWeb.pl.


Pre-requisites:
-----------------------

Please check Pre-requisites.txt 


Setting Configuration files.
----------------------------------
1. ConfluenceConfig.conf

This file contains all parameters required by harness to 
connect to remote confluence server and extract spaces.

Example: ServerURL=http://Confluenceserver:8080
Please check ConfluenceConfig.conf for description of each paramter 

2. ConvertorConfig.conf

This file contains various paramters used by harness 
for successfull run, also various twiki paramters can be 
be set in here.

Example: Debug=off
Please check ConvertorConfig.conf for description of each paramter 


Using genTWikiWeb.pl
----------------------------------------------------------------
Note: Login as root on unix boxes
----------------------------------------------------------------
1. Command line execution-
<basedir>/<src>/perl -I ../lib -I <twiki installed lib dir> genTWikiWeb.pl


Ex. Let us assume basedir is /root/confluence2twiki 
   #cd /root/confluence2twiki/src/
   #perl -I ../lib -I /var/www/twiki/lib genTWikiWeb.pl 

2. genTWikiWeb will convertor all web spaces which are downloaded 
in <basedir>/xml directory.


Checking Logs
------------------

1.Log file is generated in <basedir> with the name as given in 
 ConvertorConfig.conf

2.<basedir>Exported_URLS contains URL`s list of downloaded Confluence web spaces.



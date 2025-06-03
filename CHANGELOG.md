## 2025-05-09 0.8.0
* Drop legacy facts

## 2025-02-17 0.7.1
* fix up peer template

## 2025-02-17 0.7.0
* drop service parameter
* Drop nagios support
* Fix up lint
* disable beaker tests

## 2021-05-07 0.5.9
* Update type to use a newer version of puppetlabs-stdlib

## 2018-04-03 0.5.2
* the validate command is still not working as expected so i have implmented a work around pending [PUP-8983](https://tickets.puppetlabs.com/browse/PUP-8983)

## 2018-04-03 0.5.1
* BUG: frr does does not set CAP\_DAC\_OVERRIDE  when switching users even if switching to the root user.  therefore we need to manage user permissions of bgpd.conf file and pass correct user to the validate command
* convert to PDK

## 2018-04-03 0.5.0
* run validate command as root user

## 2018-04-03 0.4.11
* Add abbility to specify listen address for bgp

## 2018-03-29 0.4.10
* Add dependecy for package on all ini settings

## 2018-02-13 0.4.9
* Add bogon filters

## 2018-02-12 0.4.8
* FIX: correct validate\_cmd string

## 2018-02-12 0.4.7
* add validate\_cmd to concat file

## 2018-02-08 0.4.6
* FIX: error with reject prefix ACL and add spec tests

## 2018-02-08 0.4.5
* FIX: prefix lists have to have a le value greater then the prefix size

## 2018-02-08 0.4.4
* update dependencies

## 2018-02-07 0.4.3
* update dependencies

## 2018-02-07 0.4.2
* update dependencies

## 2018-02-07 0.4.1
* update dependencies

## 2018-02-07 0.4.0
* add support to reject recived prefixes

## 2016-08-09 0.3.1
* add support to control logging

## 2016-08-02 0.3.0
* add support to control logging

## 2016-05-20 0.2.4
* Fix bug which prevented failover networks from been advertised
* add beaker tests for disable_advertisment, failover networks and failsafe_server

## 2016-05-20 0.2.3
* Fix bug preventing multible peers
* add beaker and rspec tests for multible peers

## 2016-05-19 0.2.2
* Fix the change log

## 2016-05-19 0.2.1
* minor fixs to docs

## 2016-05-19 0.2.0
* Refactor module to add spec and beaker tests

## 2015-05-11 v0.1.3
* add BGP MD5 passport support

## 2015-03-27 v0.1.2
* Initial Release

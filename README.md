[![Build Status](https://travis-ci.org/icann-dns/puppet-frr.svg?branch=master)](https://travis-ci.org/icann-dns/puppet-frr)
[![Puppet Forge](https://img.shields.io/puppetforge/v/icann/frr.svg?maxAge=2592000)](https://forge.puppet.com/icann/frr)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/icann/frr.svg?maxAge=2592000)](https://forge.puppet.com/icann/frr)
# Frr

### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with frr](#setup)
    * [What frr affects](#what-frr-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with frr](#beginning-with-frr)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

Manage the installation and configuration of Frr (Routing Daemons) .

## Module Description

This modules allows for the manging of the frr BGP daemon. Other routing modules are currently unsupported however you should be able to configure them manuly

## Setup

### What frr affects

* Manages the frr configueration file
* Manages the frr bgpd configueration file
* can export nagios\_service to test neighbours are Established and routes are being advertised

### Setup Requirements

* depends on stdlib 4.11.0 (may work with earlier versions)

### Beginning with frr

Install the package an make sure it is enabled and running with default options, this will just configure zebra to run with no bgp config:

```puppet
class { '::frr': }
```

With some bgp peers

```puppet
class { '::frr': }
class { '::frr::bgpd':
  my_asn => 64496,
  router_id => '192.0.2.1',
  networks4 => [ '192.0.2.0/24'],
  peers => {
    '64497' => {
      'addr4' => ['192.0.2.2'],
      'desc'  => 'TEST Network'
    }
  }
}
```

and in hiera

```yaml
my_asn: 64496,
router_id: 192.0.2.1
networks4:
- '192.0.2.0/24'
peers:
  64497:
    addr4:
    - '192.0.2.2'
    desc: TEST Network
```

## Usage

Add config but disable advertisments and add nagios checks

```puppet
class { '::frr::bgpd':
  my_asn => 64496,
  router_id => '192.0.2.1',
  networks4 => [ '192.0.2.0/24'],
  enable_advertisements => false,
  peers => {
    '64497' => {
      'addr4' => ['192.0.2.2'],
      'desc'  => 'TEST Network'
    }
  }
}
```

Full config

```puppet
class { '::frr::bgpd':
  my_asn                   => 64496,
  router_id                => '192.0.2.1',
  networks4                => [ '192.0.2.0/24', '10.0.0.0/24'],
  failsafe_networks4       => ['10.0.0.0/23'],
  networks6                => ['2001:DB8::/48'],
  failsafe_networks6       => ['2001:DB8::/32'],
  enable_advertisements    => false,
  enable_advertisements_v4 => false,
  enable_advertisements_v6 => false,
  manage_nagios            => true,
  peers => {
    '64497' => {
      'addr4'          => ['192.0.2.2'],
      'addr6'          => ['2001:DB8::2'],
      'desc'           => 'TEST Network',
      'inbound_routes' => 'all',
      'communities'    => ['no-export', '64497:100' ],
      'multihop'       => 5,
      'password'       => 'password',
      'prepend'        => 3,
    }
  }
}
```

## Limitations

This module has been tested on:

* Ubuntu 12.04, 14.04

## Development

Pull requests welcome but please also update documentation and tests.

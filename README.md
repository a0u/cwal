# CWAL

`cwal` is an `m4` macro library for generating shell scripts to automate
the low-level installation of BSD and GNU/Linux hosts.

Its name is a reference to the cheat code for instant unit production in
a particular RTS game, reflecting the desire to eliminate delays from
manual drudgery.

## Design

`cwal` handles the initial bootstrapping within a live CD/USB
environment to provision a self-sufficient base system.
The result is intended to be a fairly generic instance from a user
perspective, amenable to further specialization (configuration and
deployment of specific services) through a configuration management tool
such as Ansible.

Although similar in objective to Debian preseed and Red Hat kickstart,
shell-based execution enables finer-grained control than what is
normally possible with mainstream installers: custom partitioning
schemes, block device encryption, OS hardening, etc.

Particular emphasis is placed on _minimalism_:

* **Concise parameterization**:
  Machine-specific install scripts are expanded from terse declarative
  configurations.
  The macro DSL aims to enhance composability of different options while
  minimizing boilerplate and redundancy.
* **Standard infrastructure**:
  The shell scripts rely only on external utilities included with the
  stock live CD/USB installer images released by the distro maintainer;
  no additional packages are required.
* **Single file**:
  The output is a self-contained script to simplify deployment using
  command-line HTTP clients (`fetch(1)`).

For a local machine, the installation flow generally consists of several
distinct phases:

1. Volume partitioning
1. Filesystem formatting
1. Distribution download and extraction
1. Kernel and initramfs build (if applicable)
1. Bootloader configuration

## Requirements

* Build
  * POSIX.1-compliant `m4` (e.g., BSD and GNU `m4`)
  * GNU `make`
* Run
  * FreeBSD: [network install images](https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/12.0/)
    (`*-bootonly.iso` or `*-mini-memstick.img`)
  * EC2: [AWS CLI](https://aws.amazon.com/cli/)

## Addendum

* Default root password: `can'twaitanylonger`

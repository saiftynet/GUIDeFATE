#!/usr/bin/perl

use strict;
use warnings;
use Test::More;

if (!$ENV{RELEASE_TESTING}) {
    plan skip_all => 'These tests are for only for release candidate testing. Enable with RELEASE_TESTING=1';
}

eval "use Test::Kwalitee";
plan skip_all => 'Test::Kwalitee required' if $@;

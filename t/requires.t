#!/usr/bin/perl -w

################################################################
#
# Copyright (c) 1995-2014 SUSE Linux Products GmbH
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 or 3 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program (see the file COPYING); if not, write to the
# Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA
#
################################################################

use strict;
use Test::More tests => 7;
use Build;
use Data::Dumper;

sub expand {
  my ($c, @r) = Build::expand(@_);
  return ($c, sort(@r));
}

my $config = Build::read_config('x86_64');
Build::readdeps($config, undef, "t/requires.repo");
my $config2 = Build::read_config('x86_64', [
  'Prefer: d',
]);
Build::readdeps($config2, undef, "t/requires.repo");
my $config3 = Build::read_config('x86_64', [
  'Prefer: -d',
]);
Build::readdeps($config3, undef, "t/requires.repo");

my @r;

@r = expand($config);
is_deeply(\@r, [1], 'install nothing');

@r = expand($config, 'n');
is_deeply(\@r, [undef, 'nothing provides n'], 'install n');

@r = expand($config, 'f');
is_deeply(\@r, [undef, 'nothing provides n needed by f'], 'install f');

@r = expand($config, "a");
is_deeply(\@r, [1, 'a', 'b'], 'install a');

@r = expand($config, "c");
is_deeply(\@r, [undef, 'have choice for p needed by c: d e'], 'install c');

@r = expand($config2, "c");
is_deeply(\@r, [1, 'c', 'd'], 'install c with prefer');

@r = expand($config3, "c");
is_deeply(\@r, [1, 'c', 'e'], 'install c with neg prefer');
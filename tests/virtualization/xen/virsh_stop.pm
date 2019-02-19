# Copyright (C) 2019 SUSE LLC
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, see <http://www.gnu.org/licenses/>.
#
# Summary: Stop all libvirt guests
# Maintainer: Pavel Dostál <pdostal@suse.cz>

use base "consoletest";
use xen;
use strict;
use testapi;
use utils;

sub run {
    my ($self) = @_;
    my $hypervisor = get_required_var('QAM_XEN_HYPERVISOR');

    assert_script_run "ssh root\@$hypervisor 'virsh shutdown $_'" foreach (keys %xen::guests);
    for (my $i = 0; $i <= 120; $i++) {
        if (script_run("ssh root\@$hypervisor 'virsh list --all | grep -v Domain-0 | grep running'") == 1) {
            last;
        }
        sleep 1;
    }
}

sub test_flags {
    return {fatal => 1, milestone => 0};
}

1;


# SUSE's openQA tests
#
# Copyright © 2009-2013 Bernhard M. Wiedemann
# Copyright © 2012-2016 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

use base "x11test";
use testapi;

sub run() {
    my $self = shift;
    ensure_installed("Mesa-demo-x");
    x11_start_program("glxgears");
    assert_screen 'test-glxgears-1', 3;
    send_key "alt-f4";
}

1;
# vim: set sw=4 et:

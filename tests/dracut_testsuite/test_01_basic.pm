# SUSE's openQA tests
#
# Copyright © 2019 SUSE LLC
#
# Copying and distribution of this file, with or without modification,
# are permitted in any medium without royalty provided the copyright
# notice and this notice are preserved.  This file is offered as-is,
# without any warranty.

# Summary: Run test executed by TEST-01-BASIC from upstream after openSUSE/SUSE patches.
# Maintainer: Sergio Lindo Mansilla <slindomansilla@suse.com>, Thomas Blume <tblume@suse.com>

use base "consoletest";
use warnings;
use strict;
use testapi;
use utils 'zypper_call';
use power_action_utils 'power_action';
use main_common;

sub run {
    my $qa_head_repo = get_var('QA_HEAD_REPO', '');
    if (!$qa_head_repo) {
        if (is_leap('15.0+')) {
            $qa_head_repo = 'https://download.opensuse.org/repositories/devel:/openSUSE:/QA:/Leap:/15/openSUSE_Leap_15.0/';
        }
        elsif (is_sle('15+')) {
            $qa_head_repo = 'http://download.suse.de/ibs/QA:/SLE15/standard/';
        }
        die '$qa_head_repo is not set' unless ($qa_head_repo);
    }

    select_console 'root-console';

    # install dracut and testsuite
    zypper_call "ar $qa_head_repo dracut-testrepo";
    zypper_call '--gpg-auto-import-keys ref';
    zypper_call 'in --force --from dracut-testrepo dracut';
    zypper_call 'in dracut-qa-testsuite';

    #setup and run first test
    assert_script_run 'cd /var/opt/dracut-tests/TEST-01-BASIC';
    assert_script_run './test.sh --setup 2>&1 | tee ../logs/TEST-01-BASIC-setup.log', 300;
    assert_screen("dracut-root-block-created");
    power_action('reboot', textmode => 1);
    assert_screen("dracut-root-block-success", 80);
    sleep 5;
    #cleanup previous test and prepare next one
    assert_screen("linux-login", 180);
    type_string "root\n";
    wait_still_screen 3;
    type_password;
    wait_still_screen 3;
    send_key 'ret';
    assert_script_run 'cd /var/opt/dracut-tests/TEST-01-BASIC';
    assert_script_run './test.sh --clean, 20';
    assert_script_run 'cd /var/opt/dracut-tests/TEST-02-SYSTEMD';
}

# sub test_flags {
#    return { always_rollback => 1 };
# }

sub post_fail_hook {
    my ($self) = shift;
    $self->SUPER::post_fail_hook;
    assert_script_run('tar -cjf dracut-testsuite-logs.tar.bz2 /var/opt/dracut-tests/logs', 600);
    upload_logs('dracut-testsuite-logs.tar.bz2');
}


1;

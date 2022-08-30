#!/bin/bash

CALL_POPD=false
if [[ "$PWD" != */scripts ]]; then
    pushd scripts &>/dev/null
fi

# Source the functions in other files
. certificates.sh
. install.sh
. user.sh

usage() {
    echo "USAGE:"
    echo "sudo ./scripts/setup.sh certs"
    echo "    Setup for running \"bpfd\" in foreground or background and straight"
    echo "    from build directory. No \"bpfd\" or \"bpfctl\" users are created so"
    echo "    always need \"sudo\" when executing \"bptctl\" commands. Performs the"
    echo "    following tasks:"
    echo "    * Create \"/etc/bpfd/\" and \"/etc/bpfctl/\" directories."
    echo "    * Copy a default \"bpfd.toml\" and \"bpfctl.toml\" if needed."
    echo "    * Create certs for \"bpfd\" and \"bpfctl\" if needed."
    echo "    * To run \"bpfd\":"
    echo "          sudo RUST_LOG=info ./target/debug/bpfd"
    echo "          <CTRL-C>"
    echo "sudo ./scripts/setup.sh del"
    echo "    Unwinds all actions performed by \"setup.sh certs\"."
    echo "----"
    echo "sudo ./scripts/setup.sh init"
    echo "    Setup for running \"bpfd\" in foreground or background and straight"
    echo "    from build directory, but also creates the \"bpfd\" or \"bpfctl\" users"
    echo "     and user groups. Performs the following tasks:"
    echo "    * Create User/Group \"bpfd\" and \"bpfctl\"."
    echo "    * Create \"/etc/bpfd/\" and \"/etc/bpfctl/\" directories and set user"
    echo "      group for each."
    echo "    * Copy a default \"bpfd.toml\" and \"bpfctl.toml\" if needed."
    echo "    * Create certs for \"bpfd\" and \"bpfctl\" if needed."
    echo "    * To run \"bpfd\":"
    echo "          sudo RUST_LOG=info ./target/debug/bpfd"
    echo "          <CTRL-C>"
    echo "    * Optionally, to run \"bpfctl\" without sudo, add usergroup \"bpfctl\""
    echo "      to desired user and logout/login to apply:"
    echo "          sudo usermod -a -G bpfctl \$USER"
    echo "          exit"
    echo "          <LOGIN>"
    echo "sudo ./scripts/setup.sh del"
    echo "    Unwinds all actions performed by \"setup.sh init\"."
    echo "----"
    echo "sudo ./scripts/setup.sh install"
    echo "    Setup for running \"bpfd\" as a systemd service. Performs the following"
    echo "    tasks:"
    echo "    * Perform all actions performed by \"setup.sh init\"."
    echo "    * Copy \"bpfd\" and \"bpfctl\" binaries to \"/usr/sbin/.\" and set"
    echo "      the user group for each."
    echo "    * Copy \"bpfd.service\" to \"/usr/lib/systemd/system/\"."
    echo "    * Use \"systemctl\" to mange the service:"
    echo "          sudo systemctl start bpfd.service"
    echo "          sudo systemctl stop bpfd.service"
    echo "sudo ./scripts/setup.sh reinstall"
    echo "    Only copy the \"bpfd\" and \"bpfctl\" binaries to \"/usr/sbin/.\""
    echo "    and set the user group for each. \"bpfd\" service will be restarted"
    echo "    if running. Installed programs will need to be loaded again."
    echo "sudo ./scripts/setup.sh uninstall"
    echo "    Unwind all actions performed by \"setup.sh install\" including stopping"
    echo "    the \"bpfd\" service if it is running."
    echo "----"
    echo "sudo ./scripts/setup.sh gocounter"
    echo "    Create the certs for the \"gocounter\" example."
    echo "sudo ./scripts/setup.sh regen"
    echo "    Regenerate all existing certs."
    echo ""
}

if [ $USER != "root" ]; then
    echo "ERROR: \"root\" or \"sudo\" required."
    exit
fi

case "$1" in
    "certs")
        user_dir
        cert_init false
        ;;
    "init")
        user_init
        cert_init false
        ;;
    "del"|"delete")
        user_del
        ;;
    "install")
        user_init
        cert_init false
        install false
        ;;
    "reinstall")
        install true
        ;;
    "uninstall")
        uninstall
        user_del
        ;;
    "gocounter")
        cert_client gocounter bpfctl false
        ;;
    "regen")
        cert_init true
        ;;
    "help"|"--help"|"?")
        usage
        ;;
    *)
        echo "Unknown input: $1"
        echo
        usage
        ;;
esac

if [[ "$CALL_POPD" == true ]]; then
    popd &>/dev/null
fi
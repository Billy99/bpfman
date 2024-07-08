# Run bpfman From RPM

This section describes how to deploy `bpfman` from an RPM.
RPMs are generated each time a Pull Request is merged in github for Fedora 38, 39 and
Rawhide (see [Install Prebuilt RPM](#install-prebuilt-rpm) below).
RPMs can also be built locally from a Fedora server
(see [Build RPM Locally](#build-rpm-locally) below).

## Install Prebuilt RPM

This section describes how to install an RPM built automatically by the
[Packit Service](https://dashboard.packit.dev/projects/github.com/bpfman/bpfman).
The Packit Service builds RPMs for each Pull Request merged.

### Packit Service Prerequisites

To install an RPM generated by the Packit Service, the following packages need
to be installed:

`dnf` based OS:

```console
sudo dnf install -y dnf-plugins-core
```

To install officially released versions:

```console
sudo dnf copr enable @ebpf-sig/bpfman
```

To install nightly builds:

```console
sudo dnf copr enable @ebpf-sig/bpfman-next
```

> **Note:** If both the bpfman and bpfman-next copr repos are enabled DNF will
> automatically pull from bpfman-next.  To disable one or the other simply run
> ```console
> sudo dnf copr disable @ebpf-sig/bpfman-next
> ```

### Install RPM From Packit Service

To load a RPM from a specific commit (@ebpf-sig/bpfman-next needs to be enabled
instead of @ebpf-sig/bpfman), find the commit from [bpfman commits](https://github.com/bpfman/bpfman/commits/main/), and click on the green check showing a given Pull Request was verified.
At the bottom of the list of checks are the RPM builds, click on the `details`,
and follow the Packit Dashboard link to the `Copr Build Results`.
Then install the given RPM:

```console
sudo dnf install -y bpfman-0.4.0~dev-1.20240117143006587102.main.191.gda44a71.fc38.x86_64
```

`bpfman` is now installed but not running.
To start `bpfman`:

```console
sudo systemctl daemon-reload
sudo systemctl enable bpfman.socket
sudo systemctl start bpfman.socket
```

Verify `bpfman` is installed and running:

```console
$ sudo systemctl status bpfman.socket
● bpfman.socket - bpfman API Socket
     Loaded: loaded (/usr/lib/systemd/system/bpfman.socket; enabled; preset: disabled)
     Active: active (listening) since Thu 2024-01-18 21:19:29 EST; 5s ago
   Triggers: ● bpfman.service
     Listen: /run/bpfman-sock/bpfman.sock (Stream)
     CGroup: /system.slice/bpfman.socket
:

$ sudo systemctl status bpfman.service
○ bpfman.service - Run bpfman as a service
     Loaded: loaded (/usr/lib/systemd/system/bpfman.service; static)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: inactive (dead)
TriggeredBy: ● bpfman.socket
:

$ sudo bpfman list
 Program ID  Name  Type  Load Time

```

### Uninstall Given RPM

To determine the RPM that is currently loaded:

```console
$ sudo rpm -qa | grep bpfman
bpfman-0.4.0~dev-1.20240117143006587102.main.191.gda44a71.fc39.x86_64
```

To stop bpfman and uninstall the RPM:

```console
sudo systemctl stop bpfman.socket
sudo systemctl disable bpfman.socket

sudo dnf erase -y bpfman-0.4.0~dev-1.20240117143006587102.main.191.gda44a71.fc39.x86_64

sudo systemctl daemon-reload
```

## Build RPM Locally

This section describes how to build and install an RPM locally.

### Local Build Prerequisites

To build locally, the following packages need to be installed:

`dnf` based OS:

```console
sudo dnf install packit
sudo dnf install cargo-rpm-macros
```

> NOTE: `cargo-rpm-macros` needs to be version 25 or higher.
> It appears this is only available on Fedora 37, 38, 39 and Rawhide at the moment.

### Build Locally

To build locally, run the following command:

```console
packit build locally
```

This will generate several RPMs in a `x86_64/` directory:

```console
$ ls x86_64/
bpfman-0.4.1-1.20240521101705214906.main.19.b47994a3.fc39.x86_64.rpm
bpfman-debuginfo-0.4.1-1.20240521101705214906.main.19.b47994a3.fc39.x86_64.rpm
bpfman-debugsource-0.4.1-1.20240521101705214906.main.19.b47994a3.fc39.x86_64.rpm
```

If local RPM builds were previously run on the system, the `packit build locally` command may
fail with something similar to:

```console
packit build locally
2024-05-21 10:00:03.904 base_git.py       INFO   Using user-defined script for ActionName.post_upstream_clone: [['bash', '-c', 'if [[ ! -d /var/tmp/cargo-vendor-filterer ]]; then git clone https://github.com/coreos/cargo-vendor-filterer.git /var/tmp/cargo-vendor-filterer; fi && cd /var/tmp/cargo-vendor-filterer && cargo build && cd - && cp /var/tmp/cargo-vendor-filterer/target/debug/cargo-vendor-filterer . && ./cargo-vendor-filterer --format tar.gz --prefix vendor bpfman-bpfman-vendor.tar.gz']]
2024-05-21 10:00:03.956 logging.py        INFO   error: could not find `Cargo.toml` in `/var/tmp/cargo-vendor-filterer` or any parent directory
2024-05-21 10:00:03.957 commands.py       ERROR  Command 'bash -c if [[ ! -d /var/tmp/cargo-vendor-filterer ]]; then git clone https://github.com/coreos/cargo-vendor-filterer.git /var/tmp/cargo-vendor-filterer; fi && cd /var/tmp/cargo-vendor-filterer && cargo build && cd - && cp /var/tmp/cargo-vendor-filterer/target/debug/cargo-vendor-filterer . && ./cargo-vendor-filterer --format tar.gz --prefix vendor bpfman-bpfman-vendor.tar.gz' failed.
2024-05-21 10:00:03.957 utils.py          ERROR  Command 'bash -c if [[ ! -d /var/tmp/cargo-vendor-filterer ]]; then git clone https://github.com/coreos/cargo-vendor-filterer.git /var/tmp/cargo-vendor-filterer; fi && cd /var/tmp/cargo-vendor-filterer && cargo build && cd - && cp /var/tmp/cargo-vendor-filterer/target/debug/cargo-vendor-filterer . && ./cargo-vendor-filterer --format tar.gz --prefix vendor bpfman-bpfman-vendor.tar.gz' failed.
```

To fix, run:

```console
sudo rm -rf /var/tmp/cargo-vendor-filterer/
```

### Install Local Build

Install the RPM:

```console
sudo rpm -i x86_64/bpfman-0.4.1-1.20240521101705214906.main.19.b47994a3.fc39.x86_64.rpm
```

`bpfman` is now installed but not running.
To start `bpfman`:

```console
sudo systemctl daemon-reload
sudo systemctl enable bpfman.socket
sudo systemctl start bpfman.socket
```

Verify `bpfman` is installed and running:

```console
$ sudo systemctl status bpfman.socket
● bpfman.socket - bpfman API Socket
     Loaded: loaded (/usr/lib/systemd/system/bpfman.socket; enabled; preset: disabled)
     Active: active (listening) since Thu 2024-01-18 21:19:29 EST; 5s ago
   Triggers: ● bpfman.service
     Listen: /run/bpfman-sock/bpfman.sock (Stream)
     CGroup: /system.slice/bpfman.socket
:

$ sudo systemctl status bpfman.service
○ bpfman.service - Run bpfman as a service
     Loaded: loaded (/usr/lib/systemd/system/bpfman.service; static)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: inactive (dead)
TriggeredBy: ● bpfman.socket
:

$ sudo bpfman list
 Program ID  Name  Type  Load Time

```

### Uninstall Local Build

To determine the RPM that is currently loaded:

```console
$ sudo rpm -qa | grep bpfman
bpfman-0.4.1-1.20240521101705214906.main.19.b47994a3.fc39.x86_64
```

To stop bpfman and uninstall the RPM:

```console
sudo systemctl stop bpfman.socket
sudo systemctl disable bpfman.socket

sudo rpm -e bpfman-0.4.1-1.20240521101705214906.main.19.b47994a3.fc39.x86_64

sudo systemctl daemon-reload
```
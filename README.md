# docker-virtualbox

The official [Docker Desktop on Windows](https://docs.docker.com/desktop/install/windows-install/) provides two options for the backend:

* Hyper-V
* [WSL 2](https://learn.microsoft.com/en-us/windows/wsl/faq#wsl-2), which utilizes the "Virtual Machine Platform" (a subset of Hyper-V)

Unfortunately, this leads to limitations and restrictions when using other (type 2) hypervisors, such as [VirtualBox](https://www.virtualbox.org/).

As an alternative to Docker Desktop, this repository provides a [Vagrant](https://www.vagrantup.com/) configuration for provisioning a VirtualBox VM containing the Docker service.

## Installation

VirtualBox and Vagrant must be installed before continuing.

### Usage

To provision the VM containing the Docker service, run `vagrant up`.

Once completed, you can access the machine via `ssh`:

```
vagrant ssh
```

To shutdown the machine:

```
vagrant halt
```

To remove the machine:

```
vagrant destroy
```

To create shared folders for this VM:
```
PS C:\> cd 'C:\Program Files\Oracle\VirtualBox\'
PS C:\Program Files\Oracle\VirtualBox> .\VBoxManage.exe sharedfolder add "docker-vagrant" --name="sharename" --hostpath="C:\test" --automount --auto-mount-point="/test"
```

Refer to the documentation on the [Vagrant](https://www.vagrantup.com) website for more information.

### Local Docker CLI (optional)

To install Docker (server and client) binaries and Docker Compose locally, open Powershell as Administrator and run `install_docker.ps1`.

## Local development using VSCode

1. Install the "Remote - SSH" extension by Microsoft.
2. In the repository root, dump the vagrant SSH configuration:

```
vagrant ssh-config
```

3. Create a new SSH host in VSCode, using the configuration from the previous step.

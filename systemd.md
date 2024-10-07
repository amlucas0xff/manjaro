
### Create a systemd unit file to run a command at system startup

This guide will show you how to create a `systemd` unit file. This file makes sure a command runs every time your Manjaro Linux system starts. 

---
#### What is a systemd Unit File?
A _systemd unit file_ is used to control when a service or command runs in your system. By creating this file, you can make sure that a script or program starts automatically when your system boots.
##### Parts of the systemd Unit File
The unit file has three main sections: `[Unit]`, `[Service]`, and `[Install]`.
##### **\[Unit\] Section**
This part gives basic information about the service:
- **Description**: A short explanation of what the service does.
- **After=network.target**: This means the service will only start after the network is up. This does not create a strict dependency; it just waits for the network.
##### **\[Service\] Section**
This part describes how the service runs:
- **Type=simple**: This tells `systemd` that the service runs as a single process.
- **User=root**: The service will run as the root user
- **ExecStart**: The full path to the script or command that will run when the service starts.
- **Restart=always**: If the service stops for any reason, it will restart automatically.
- **RestartSec=30**: The service will wait 30 seconds before restarting.
##### **\[Install\] Section**
This part explains when the service should start:
- **WantedBy=multi-user.target**: This tells `systemd` to start the service when the system is in multi-user mode. Multi-user mode is the state when the system is fully started, but without a graphical interface.
---
#### How to Create the Unit File
Open a terminal.
Use `vim` to create the systemd unit file:

```shell
sudo vim /etc/systemd/system/service-name.service
```

> [!NOTE]
> * Place user-created service files in `/etc/systemd/system`
> * System-installed services go in `/usr/lib/systemd/system`

```plaintext
[Unit]
Description=Description for your service
After=network.target

[Service]
Type=simple
User=root
ExecStart=/full/path/to/your/service/execution
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
```

Once the unit file is created, you need to enable and start it.
Enable the service so it starts automatically when your system boots:

```shell
sudo systemctl enable service-name.service
```

Start the service immediately:
```
sudo systemctl start service-name.service
```

Check the status of the service to make sure it’s running:
```shell
sudo systemctl status service-name.service
```

#### Troubleshooting  
If your service doesn’t work as expected, you can check for errors:

Check the service status:
```shell
sudo systemctl status service-name.service
```

View detailed logs:
```shell
sudo journalctl -u service-name.service
```

Make sure the script path (`ExecStart`) is correct, and that your script has executable permissions.

---

If you're using KDE, consider `systemdgenie`, a graphical frontend for systemctl. It’s one of the few graphical editors available for systemd and is worth checking out. You can install it within Manjaro with the following command:

```shell
pamac install systemdgenie
```

Systemd offers many more features beyond launching scripts at boot. For further details, refer to the Arch Documentation: [https://wiki.archlinux.org/title/Systemd](https://wiki.archlinux.org/title/Systemd)
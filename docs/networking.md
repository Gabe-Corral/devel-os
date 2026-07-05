# Networking

DevelOS uses NetworkManager for wired and wireless networking. Use `nmcli` from a terminal to connect to Wi-Fi, inspect devices, and manage saved connections.

## Check Status

```bash
nmcli device status
nmcli connection show
```

## Connect To Wi-Fi

List nearby networks:

```bash
nmcli device wifi list
```

Connect to a network:

```bash
nmcli device wifi connect "SSID" password "password"
```

For open networks, omit the password:

```bash
nmcli device wifi connect "SSID"
```

## Reconnect Later

NetworkManager saves successful connections. To reconnect manually:

```bash
nmcli connection up "SSID"
```

## Troubleshooting

Check that NetworkManager is running:

```bash
systemctl status NetworkManager.service
```

If Wi-Fi is blocked, inspect rfkill state:

```bash
rfkill list
```

Unblock Wi-Fi:

```bash
rfkill unblock wifi
```

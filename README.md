# Pangolin bar widget for Omarchy

An [Omarchy](https://omarchy.org/) shell (Quickshell) bar widget for the
[Pangolin](https://github.com/fosrl/pangolin) VPN client. Adds an icon to the
bar (tinted to your theme's foreground color) that shows whether you're
connected, and opens a popup with connection details and a
connect/disconnect button.

## Features

- Bar icon tinted to match your current Omarchy theme
- Click to open a popup showing connection status, org, IP address, site, and
  version
- Connect/Disconnect button (opens a floating terminal, since `pangolin
  up`/`down` need a real TTY for their `sudo` prompt)
- Right-click for a full `pangolin status` view in a terminal
- First-run "Setup" button when Pangolin isn't logged in yet, which opens
  `pangolin login` in a terminal

## Requirements

- The [Pangolin CLI](https://github.com/fosrl/pangolin) installed and on
  `PATH` as `pangolin` (e.g. the `pangolin-bin` AUR package)
- `sudo` configured normally (you'll be prompted for your password when
  connecting/disconnecting)

## Install

```bash
omarchy plugin add https://github.com/4A616D6573/omarchy-pangolin.git --enable
```

This enables the widget on the right side of the bar by default. Move it
with `omarchy bar move io.github.4a616d6573.pangolin --section <left|center|right>`.

If you haven't installed or logged in to Pangolin yet, click the widget and
use the **Setup** button — it walks you through `pangolin login` in a
terminal.

## Remove

```bash
omarchy plugin remove io.github.4a616d6573.pangolin
```

This only removes the plugin files; it does not uninstall the Pangolin CLI
or affect any existing Pangolin connection/login.

## License

MIT — see [LICENSE](LICENSE).

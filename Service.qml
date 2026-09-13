import QtQuick
import Quickshell
import Quickshell.Io
import "Model.js" as Model

Item {
  id: root

  property bool connected: false
  property bool installed: true
  property bool authenticated: false
  property string orgId: ""
  property string ip: ""
  property string siteName: ""
  property string endpoint: ""
  property string version: ""
  property string lastError: ""
  readonly property bool busy: statusProcess.running

  function refresh() {
    if (!statusProcess.running) statusProcess.running = true
    if (!authProcess.running) authProcess.running = true
  }

  function applyStatus(raw) {
    var parsed = Model.parseStatus(raw)
    if (!parsed.ok) {
      lastError = parsed.lastError || "Failed to read Pangolin status"
      return
    }
    connected = parsed.connected === true
    orgId = parsed.orgId || ""
    ip = parsed.ip || ""
    siteName = parsed.siteName || ""
    endpoint = parsed.endpoint || ""
    version = parsed.version || ""
    lastError = ""
  }

  // `pangolin up`/`down` shell out to sudo, which needs a real TTY to prompt
  // for a password — so these run in a floating terminal rather than
  // detached, and the settle timer polls faster afterward to pick up the
  // change without waiting for the next periodic refresh.
  function connectClient() {
    Quickshell.execDetached(["bash", "-lc", "omarchy-launch-tui pangolin up"])
    settleTimer.ticks = 0
    settleTimer.running = true
  }

  function disconnectClient() {
    Quickshell.execDetached(["bash", "-lc", "omarchy-launch-tui pangolin down"])
    settleTimer.ticks = 0
    settleTimer.running = true
  }

  function toggle() {
    if (connected) disconnectClient()
    else connectClient()
  }

  function viewStatus() {
    Quickshell.execDetached(["bash", "-lc", "omarchy-launch-tui bash -c \"pangolin status; read -p 'Press enter to close'\""])
  }

  // `pangolin login` walks through an interactive hosting/account flow, so
  // it needs a real terminal like `up`/`down` does. The settle timer picks
  // up the newly-authenticated state once the user finishes and closes it.
  function setup() {
    Quickshell.execDetached(["bash", "-lc", "omarchy-launch-tui pangolin login"])
    settleTimer.ticks = 0
    settleTimer.running = true
  }

  Timer {
    interval: 5000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  Timer {
    id: settleTimer
    property int ticks: 0
    interval: 2000
    repeat: true
    running: false
    onTriggered: {
      ticks += 1
      root.refresh()
      if (ticks >= 8) running = false
    }
  }

  Process {
    id: statusProcess
    running: false
    command: ["bash", "-lc", "pangolin status --json 2>/dev/null"]
    stdout: StdioCollector {
      id: statusStdout
      waitForEnd: true
      onStreamFinished: root.applyStatus(text)
    }
  }

  Process {
    id: authProcess
    running: false
    command: ["bash", "-lc", "command -v pangolin >/dev/null 2>&1 && pangolin auth status >/dev/null 2>&1"]
    onExited: function(exitCode) { root.authenticated = exitCode === 0 }
  }

  Process {
    id: installedProcess
    running: true
    command: ["bash", "-lc", "command -v pangolin >/dev/null 2>&1"]
    onExited: function(exitCode) { root.installed = exitCode === 0 }
  }
}

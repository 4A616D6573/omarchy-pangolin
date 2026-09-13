import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.4a616d6573.pangolin"
  ipcTarget: "io.github.4a616d6573.pangolin"

  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string pluginDir: Quickshell.env("HOME") + "/.config/omarchy/plugins/io.github.4a616d6573.pangolin"
  readonly property string iconPath: Quickshell.env("HOME") + "/.cache/omarchy/io.github.4a616d6573.pangolin-icon.svg"
  property int iconTick: 0

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  onBarChanged: root.renderIcon()
  onOpenedChanged: if (opened) pangolin.refresh()

  function toHex(c) {
    function channel(v) {
      var h = Math.round(Math.max(0, Math.min(1, v)) * 255).toString(16)
      return h.length < 2 ? "0" + h : h
    }
    return "#" + channel(c.r) + channel(c.g) + channel(c.b)
  }

  function renderIcon() {
    if (!root.bar) return
    iconProc.command = ["bash", "-lc", "'" + root.pluginDir + "/scripts/pangolin-icon' '" + root.toHex(root.foreground) + "' '" + root.iconPath + "'"]
    iconProc.running = true
  }

  Process {
    id: iconProc
    stdout: StdioCollector { waitForEnd: true; onStreamFinished: root.iconTick += 1 }
  }

  Service {
    id: pangolin
  }

  IpcHandler {
    target: root.ipcTarget
    function open(): void { root.open() }
    function close(): void { root.close() }
    function show(): void { root.open() }
    function hide(): void { root.close() }
    function toggle(): void { root.toggle() }
    function refresh(): string { pangolin.refresh(); return "ok" }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    opticalSize: Style.space(12)
    iconComponent: Component {
      Image {
        anchors.fill: parent
        source: "file://" + root.iconPath + "?t=" + root.iconTick
        cache: false
        fillMode: Image.PreserveAspectFit
        sourceSize.width: width
        sourceSize.height: height
      }
    }
    onPressed: function(buttonCode) {
      if (buttonCode === Qt.RightButton) pangolin.viewStatus()
      else root.toggle()
    }
  }

  KeyboardPanel {
    id: panel
    anchorItem: button
    owner: root
    bar: root.bar
    open: root.opened
    contentWidth: panel.fittedContentWidth(Style.space(280))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(360))

    Column {
      id: column
      width: panel.contentWidth - panel.padding * 2
      spacing: Style.space(12)

      PanelHero {
        width: parent.width
        title: "Pangolin"
        meta: !pangolin.authenticated ? "Not set up" : (pangolin.connected ? "Connected" : "Disconnected")
        foreground: root.foreground
        fontFamily: root.fontFamily
        iconOpacity: pangolin.authenticated && pangolin.connected ? 1.0 : 0.5
        iconComponent: Component {
          Image {
            source: "file://" + root.iconPath + "?t=" + root.iconTick
            cache: false
            fillMode: Image.PreserveAspectFit
            sourceSize.width: Style.font.display
            sourceSize.height: Style.font.display
            width: Style.font.display
            height: Style.font.display
          }
        }
      }

      PanelSeparator {
        foreground: root.foreground
      }

      Column {
        width: parent.width
        spacing: Style.space(10)
        visible: !pangolin.authenticated

        Text {
          textFormat: Text.PlainText
          width: parent.width
          text: pangolin.installed ? "Log in to start using Pangolin." : "Pangolin CLI is not installed."
          color: Qt.darker(root.foreground, 1.4)
          font.family: root.fontFamily
          font.pixelSize: Style.font.body
          wrapMode: Text.WordWrap
        }

        Button {
          width: parent.width
          bordered: true
          text: "Setup"
          enabled: pangolin.installed
          onClicked: pangolin.setup()
        }
      }

      Column {
        width: parent.width
        spacing: Style.spacing.labelGap
        visible: pangolin.authenticated && pangolin.connected

        InfoPair { label: "Org"; value: pangolin.orgId }
        InfoPair { label: "IP address"; value: pangolin.ip }
        InfoPair { label: "Site"; value: pangolin.siteName }
        InfoPair { label: "Version"; value: pangolin.version }
      }

      Text {
        textFormat: Text.PlainText
        visible: pangolin.authenticated && !pangolin.connected
        width: parent.width
        text: "Not connected to Pangolin."
        color: Qt.darker(root.foreground, 1.4)
        font.family: root.fontFamily
        font.pixelSize: Style.font.body
      }

      Text {
        textFormat: Text.PlainText
        visible: pangolin.lastError !== ""
        width: parent.width
        text: pangolin.lastError
        color: root.bar ? root.bar.urgent : Color.urgent
        font.family: root.fontFamily
        font.pixelSize: Style.font.bodySmall
        wrapMode: Text.WordWrap
      }

      Button {
        width: parent.width
        bordered: true
        visible: pangolin.authenticated
        text: pangolin.connected ? "Disconnect" : "Connect"
        onClicked: pangolin.toggle()
      }
    }
  }

  component InfoPair: Row {
    property string label: ""
    property string value: ""

    width: parent.width
    spacing: Style.space(8)
    visible: value !== ""

    Text {
      textFormat: Text.PlainText
      text: label
      color: root.foreground
      opacity: 0.6
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
    }
    Item { width: Math.max(0, parent.width - parent.children[0].implicitWidth - parent.children[2].implicitWidth - parent.spacing * 2); height: 1 }
    Text {
      textFormat: Text.PlainText
      text: value
      color: root.foreground
      font.family: root.fontFamily
      font.pixelSize: Style.font.bodySmall
      elide: Text.ElideRight
    }
  }
}

// Parses `pangolin status --json` output for the io.github.4a616d6573.pangolin plugin.

function parseStatus(raw) {
  var text = String(raw || "").trim()

  if (text === "" || text.indexOf("No client is currently running") !== -1) {
    return { ok: true, connected: false }
  }

  try {
    var data = JSON.parse(text)
    var peers = data.peers || {}
    var peerKeys = Object.keys(peers)
    var peer = peerKeys.length > 0 ? peers[peerKeys[0]] : null
    var net = data.networkSettings || {}
    var ipv4 = net.ipv4_addresses || []

    return {
      ok: true,
      connected: data.connected === true,
      version: String(data.version || ""),
      orgId: String(data.orgId || ""),
      ip: String(ipv4[0] || ""),
      siteName: peer ? String(peer.name || "") : "",
      endpoint: peer ? String(peer.endpoint || "") : ""
    }
  } catch (e) {
    return { ok: false, lastError: "Failed to parse Pangolin status" }
  }
}

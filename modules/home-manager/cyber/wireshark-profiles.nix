{ lib, config, ... }:
let
  # Brad Duncan's well-known "Host" column: shows the domain for both
  # cleartext HTTP and TLS (via SNI), falling back to the DNS response name.
  # https://unit42.paloaltonetworks.com/unit42-customizing-wireshark-changing-column-display/
  hostField = "http.host or tls.handshake.extensions_server_name or dns.resp.name";

  mkColoringRules = rules:
    builtins.toJSON (map (r: {
      "${r.name}" = {
        filter = r.filter;
        foreground = r.foreground;
        background = r.background;
        enabled = true;
      };
    }) rules);

  # A trimmed set of Wireshark's own stock coloring rules (from
  # resources/share/wireshark/coloring_rules.jsonc upstream), appended after
  # each profile's specialized rules so normal traffic still looks familiar.
  stockColoringRules = [
    {
      name = "Bad TCP";
      filter =
        "tcp.analysis.flags && !tcp.analysis.window_update && !tcp.analysis.keep_alive && !tcp.analysis.keep_alive_ack";
      foreground = "#f78787";
      background = "#12272e";
    }
    {
      name = "Checksum Errors";
      filter = ''
        eth.fcs.status=="Bad" || ip.checksum.status=="Bad" || tcp.checksum.status=="Bad" || udp.checksum.status=="Bad"'';
      foreground = "#f78787";
      background = "#12272e";
    }
    {
      name = "HTTP";
      filter = "http || tcp.port == 80 || http2 || http3";
      foreground = "#12272e";
      background = "#e4ffc7";
    }
    {
      name = "TCP SYN/FIN";
      filter = "tcp.flags & 0x02 || tcp.flags.fin == 1";
      foreground = "#12272e";
      background = "#a0a0a0";
    }
    {
      name = "TCP";
      filter = "tcp";
      foreground = "#12272e";
      background = "#e7e6ff";
    }
    {
      name = "UDP";
      filter = "udp";
      foreground = "#12272e";
      background = "#daeeff";
    }
  ];
in {
  config = lib.mkIf config.cyber.enable {
    xdg.configFile = {

      ################# CTF / packet analysis challenges #################
      "wireshark/profiles/CTF/preferences".text = ''
        gui.column.format:
        	"No.", "%m",
        	"Time", "%t",
        	"Source", "%s",
        	"Src port", "%S",
        	"Destination", "%d",
        	"Dst port", "%D",
        	"Protocol", "%p",
        	"Length", "%L",
        	"Host", "%Cus:${hostField}:0",
        	"Info", "%i"
      '';

      "wireshark/profiles/CTF/coloring_rules.jsonc".text = mkColoringRules ([
        {
          name = "Cleartext FTP credentials";
          filter = ''ftp.request.command == "USER" || ftp.request.command == "PASS"'';
          foreground = "#ffffff";
          background = "#d7263d";
        }
        {
          name = "Cleartext HTTP Basic Auth";
          filter = "http.authorization";
          foreground = "#ffffff";
          background = "#d7263d";
        }
        {
          name = "Cleartext Telnet";
          filter = "telnet";
          foreground = "#ffffff";
          background = "#d7263d";
        }
        {
          name = "HTTP POST (check for creds/uploads)";
          filter = ''http.request.method == "POST"'';
          foreground = "#12272e";
          background = "#ffd166";
        }
      ] ++ stockColoringRules);

      "wireshark/profiles/CTF/dfilter_buttons".text = ''
        # "Show in toolbar","Button Label","Filter Expression","Comment"
        # Note: embedded quotes use Wireshark's \x22 hex-escape, not \" --
        # the UAT file lexer has a documented bug parsing literal \" (see
        # the XXX comment in epan/uat_load.l), and \x22 is what Wireshark's
        # own uat_save()/uat_esc() write out for a literal double quote.
        "TRUE","FTP creds","ftp.request.command == \x22USER\x22 || ftp.request.command == \x22PASS\x22","Cleartext FTP username/password"
        "TRUE","HTTP Basic Auth","http.authorization","Cleartext HTTP Basic Authorization header"
        "TRUE","Telnet","telnet","Cleartext Telnet sessions"
        "TRUE","Contains \x22flag\x22","frame contains \x22flag\x22","Packets with the literal string flag in them"
        "TRUE","HTTP POST","http.request.method == \x22POST\x22","HTTP POST requests"
      '';

      ################# General traffic troubleshooting #################
      "wireshark/profiles/Troubleshooting/preferences".text = ''
        gui.column.format:
        	"No.", "%m",
        	"Time", "%t",
        	"Source", "%s",
        	"Src port", "%S",
        	"Destination", "%d",
        	"Dst port", "%D",
        	"Protocol", "%p",
        	"RTT", "%Cus:tcp.analysis.ack_rtt:0",
        	"DNS Time", "%Cus:dns.time:0",
        	"Info", "%i"
      '';

      "wireshark/profiles/Troubleshooting/coloring_rules.jsonc".text = mkColoringRules ([
        {
          name = "TCP Retransmission";
          filter = "tcp.analysis.retransmission";
          foreground = "#ffffff";
          background = "#a40000";
        }
        {
          name = "TCP Duplicate ACK";
          filter = "tcp.analysis.duplicate_ack";
          foreground = "#12272e";
          background = "#fffc9c";
        }
        {
          name = "High Latency (ACK RTT > 200ms)";
          filter = "tcp.analysis.ack_rtt > 0.2";
          foreground = "#12272e";
          background = "#ffd166";
        }
        {
          name = "DNS Errors (non-NOERROR rcode)";
          filter = "dns.flags.rcode != 0";
          foreground = "#ffffff";
          background = "#a40000";
        }
      ] ++ stockColoringRules);

      "wireshark/profiles/Troubleshooting/dfilter_buttons".text = ''
        # "Show in toolbar","Button Label","Filter Expression","Comment"
        "TRUE","Retransmissions","tcp.analysis.retransmission","TCP retransmitted segments"
        "TRUE","DNS errors","dns.flags.rcode != 0","DNS responses with a non-zero rcode"
        "TRUE","High latency (>200ms)","tcp.analysis.ack_rtt > 0.2","ACKs taking longer than 200ms"
        "TRUE","TCP resets","tcp.flags.reset == 1","Connection resets"
      '';

      ################# Malware / C2 traffic analysis #################
      # Column layout and the HTTP/TLS-only filter button follow Brad
      # Duncan's malware-traffic-analysis.net / Unit42 Wireshark tutorials.
      "wireshark/profiles/Malware-C2/preferences".text = ''
        gui.column.format:
        	"Time", "%t",
        	"Source", "%s",
        	"Src port", "%S",
        	"Destination", "%d",
        	"Dst port", "%D",
        	"Host", "%Cus:${hostField}:0",
        	"Info", "%i"
      '';

      "wireshark/profiles/Malware-C2/coloring_rules.jsonc".text = mkColoringRules ([
        {
          name = "DNS NXDOMAIN";
          filter = "dns.flags.rcode == 3";
          foreground = "#ffffff";
          background = "#a40000";
        }
        {
          name = "TLS on non-standard port";
          filter = "tls.handshake.type == 1 && tcp.port != 443";
          foreground = "#12272e";
          background = "#ffd166";
        }
        {
          name = "HTTP request with no User-Agent";
          filter = "http.request && !http.user_agent";
          foreground = "#12272e";
          background = "#ffd166";
        }
      ] ++ stockColoringRules);

      "wireshark/profiles/Malware-C2/dfilter_buttons".text = ''
        # "Show in toolbar","Button Label","Filter Expression","Comment"
        "TRUE","HTTP/TLS only","(http.request or tls.handshake.type eq 1) and !(ssdp)","Brad Duncan's classic filter: HTTP requests + successful TLS handshakes, minus SSDP noise"
        "TRUE","Non-standard HTTPS port","tls.handshake.type == 1 && tcp.port != 443","TLS handshakes not on tcp/443 (common C2 behavior)"
        "TRUE","DNS NXDOMAIN","dns.flags.rcode == 3","Failed DNS lookups, often DGA domains"
        "TRUE","Missing User-Agent","http.request && !http.user_agent","HTTP requests without a User-Agent header"
      '';

      ################# Wifi / 802.11 analysis #################
      # Frame-type coloring scheme (purple/orange/blue) inspired by the
      # PotatoFrames Wi-Fi profile: https://github.com/PotatoFi/PotatoFrames
      "wireshark/profiles/WiFi/preferences".text = ''
        gui.column.format:
        	"No.", "%m",
        	"Time", "%t",
        	"Source", "%s",
        	"Destination", "%d",
        	"Signal (dBm)", "%Cus:wlan_radio.signal_dbm:0",
        	"SSID", "%Cus:wlan.ssid:0",
        	"Protocol", "%p",
        	"Info", "%i"
      '';

      "wireshark/profiles/WiFi/coloring_rules.jsonc".text = mkColoringRules [
        {
          name = "802.11 Malformed/Bad FCS";
          filter = ''wlan.fcs.status == "Bad"'';
          foreground = "#ffffff";
          background = "#a40000";
        }
        {
          name = "802.11 Deauth/Disassoc";
          filter = "wlan.fc.type_subtype == 0x0c || wlan.fc.type_subtype == 0x0a";
          foreground = "#ffffff";
          background = "#d7263d";
        }
        {
          name = "802.11 Management";
          filter = "wlan.fc.type == 0";
          foreground = "#12272e";
          background = "#e4c7ff";
        }
        {
          name = "802.11 Control";
          filter = "wlan.fc.type == 1";
          foreground = "#12272e";
          background = "#ffe0b3";
        }
        {
          name = "802.11 Data";
          filter = "wlan.fc.type == 2";
          foreground = "#12272e";
          background = "#cfe8ff";
        }
      ];

      "wireshark/profiles/WiFi/dfilter_buttons".text = ''
        # "Show in toolbar","Button Label","Filter Expression","Comment"
        "TRUE","Deauth/Disassoc","wlan.fc.type_subtype == 0x0c || wlan.fc.type_subtype == 0x0a","Possible deauth attack frames"
        "TRUE","EAPOL handshake","eapol","WPA/WPA2 4-way handshake frames"
        "TRUE","Beacons","wlan.fc.type_subtype == 0x08","Beacon frames"
        "TRUE","Hide beacons","!(wlan.fc.type_subtype == 0x08)","Everything except beacon frames"
        "TRUE","Probe req/resp","wlan.fc.type_subtype == 0x04 || wlan.fc.type_subtype == 0x05","Probe requests and responses"
      '';

      ################# IH (incident handling triage) #################
      "wireshark/profiles/IH/preferences".text = ''
        gui.column.format:
        	"No.", "%m",
        	"Time", "%t",
        	"Source", "%s",
        	"Src port", "%S",
        	"Destination", "%d",
        	"Dst port", "%D",
        	"Host", "%Cus:${hostField}:0",
        	"Info", "%i"
      '';

      "wireshark/profiles/IH/dfilter_buttons".text = ''
        # "Show in toolbar","Button Label","Filter Expression","Comment"
        "TRUE","web","(http.request or tls.handshake.type eq 1) and !(ssdp)","HTTP requests + successful TLS handshakes, minus SSDP noise"
        "TRUE","web + tcp","(http.request or tls.handshake.type eq 1 or tcp.flags eq 0x0002) and !(ssdp)","web, plus raw TCP SYNs"
        "TRUE","web + tcp + dns","(http.request or tls.handshake.type eq 1 or tcp.flags eq 0x0002 or dns) and !(ssdp)","web + tcp, plus DNS queries/responses"
      '';
    };
  };
}

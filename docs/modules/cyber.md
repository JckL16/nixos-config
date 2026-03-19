# Cyber Security Toolkit

- **User only:** `cyber.enable = true;` in `home.nix`
- **File:** `modules/home-manager/cyber/default.nix`

This is a comprehensive security toolkit for CTFs, penetration testing, and security research. Enabling it automatically enables `python-dev` with security-specific Python packages.

## Python Packages

Automatically installed: pwntools, unicorn, capstone, keystone-engine, ropper, pycryptodome, cryptography, r2pipe.

## Tool Categories

### General Utilities
- Scripting languages: Ruby, Perl
- Networking: nmap, masscan, rustscan, socat, netcat
- File transfer: rsync, aria2
- Hex editors: imhex, hexyl, ghex
- JSON/XML processing: jq, yq, htmlq
- System monitoring
- Wordlists

### Binary Exploitation
- Debuggers: gdb with GEF, lldb, edb
- Disassemblers/decompilers: radare2, rizin, cutter, ghidra
- Binary analysis: binwalk, binutils, elfutils, patchelf
- ROP tools: rp++, one_gadget, pwninit
- Fuzzers: AFL++, honggfuzz, radamsa
- Dynamic analysis: strace, ltrace, valgrind
- CPU emulation: QEMU, unicorn

### Reverse Engineering
- Java: jadx, bytecode-viewer
- .NET: ILSpy
- Python: pycdc
- Mobile: apktool, dex2jar, android-tools
- String extraction: FLOSS
- Unpacking: UPX
- Protocol analysis: protobuf

### Forensics
- Disk recovery: sleuthkit, testdisk, foremost, scalpel, ddrescue
- Memory forensics: volatility3
- Network forensics: wireshark, tshark, tcpdump, ettercap, NetworkMiner
- Metadata: exiftool
- PDF analysis: pdf-parser, pdfid
- Windows forensics: regripper, evtx
- YARA
- Disk utilities: dislocker, smartmontools

### Cryptography
- Libraries: openssl, gnutls
- Encryption tools: gnupg, age
- Hash cracking: hashcat, john, fcrackzip
- Cryptanalysis: xortool
- Number theory: PARI/GP, GAP
- Certificate management: certbot

### Steganography
- ImageMagick
- steghide, stegseek, zsteg, outguess
- QR code tools: qrencode, zbar

### Web Exploitation
- Proxies: Burp Suite, OWASP ZAP, mitmproxy
- Scanners: nikto, wpscan, nuclei, wapiti
- Fuzzers: ffuf, wfuzz, feroxbuster, gobuster
- SQL injection: sqlmap
- Subdomain enumeration: amass, subfinder
- API testing: Postman, Insomnia, HTTPie
- JWT tools
- Wordlists: SecLists

## Metasploit Database

For full Metasploit functionality, enable the database at system level:

```nix
# configuration.nix
metasploit-db.enable = true;

# home.nix
cyber.enable = true;
```

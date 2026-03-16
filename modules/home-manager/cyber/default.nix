# modules/home-manager/cyber/default.nix
# Consolidated cyber security toolkit for CTFs, pentesting, and security research

{ pkgs, lib, config, ... }: {
  options = {
    cyber.enable =
      lib.mkEnableOption "Enable comprehensive cyber security toolkit";
  };

  config = lib.mkIf config.cyber.enable {
    # Auto-enable python-dev with security packages
    python-dev.enable = true;
    python-dev.packages = [
      "pwntools"
      "unicorn"
      "capstone"
      "keystone-engine"
      "ropper"
      "pycryptodome"
      "cryptography"
      "r2pipe"
    ];

    home.packages = with pkgs; [

      # ============================================================
      # GENERAL TOOLS & UTILITIES
      # ============================================================

      # === SCRIPTING LANGUAGES ===
      ruby                 # Ruby programming language
      perl                 # Perl programming language
      bash                 # Bourne Again Shell

      # === NETWORKING TOOLS ===
      netcat               # TCP/IP swiss army knife
      nmap                 # Network exploration tool and security scanner
      masscan              # Fast port scanner
      rustscan             # Modern port scanner
      traceroute           # Trace route to network host
      mtr                  # Network diagnostic tool
      whois                # Client for the whois directory service
      host                 # DNS lookup utility
      socat                # Multipurpose relay for bidirectional data transfer

      # === SSH & REMOTE ACCESS ===
      openssh              # Secure shell client and server
      sshpass              # Non-interactive ssh password authentication
      sshfs                # Mount remote filesystems over SSH

      # === FILE TRANSFER ===
      rsync                # Fast incremental file transfer
      curl                 # Command line tool for transferring data with URLs
      wget                 # Network downloader
      aria2                # Lightweight multi-protocol download utility

      # === COMPRESSION & ARCHIVING ===
      zip                  # Compression and file packaging utility
      unzip                # De-archiver for .zip files
      gzip                 # GNU zip compression utility
      bzip2                # High-quality block-sorting file compressor
      xz                   # XZ compression utilities
      p7zip                # 7z compression utility
      unrar                # Extract RAR archives
      cabextract           # Program to extract Microsoft cabinet (.CAB) files

      # === FILE UTILITIES ===
      file                 # Determine file type
      fd                   # Simple, fast alternative to find
      ripgrep              # Fast search tool (better grep)
      tree                 # Display directory tree
      ncdu                 # NCurses disk usage analyzer

      # === JSON/XML/HTML PROCESSING ===
      jq                   # Command-line JSON processor
      yq                   # Command-line YAML/XML processor
      xmlstarlet           # Command-line XML toolkit
      htmlq                # Like jq but for HTML
      pup                  # Command-line HTML parser

      # === HEX & BINARY VIEWERS ===
      xxd                  # Make a hexdump or reverse a hexdump
      hexdump              # Display file contents in hex
      hexyl                # Command-line hex viewer
      hexedit              # View and edit files in hexadecimal
      imhex                # High quality hex editor
      ghex                 # GNOME hex editor

      # === PROCESS & SYSTEM ===
      htop                 # Interactive process viewer
      btop                 # Resource monitor
      lsof                 # List open files
      inxi                 # Full featured system information script
      iproute2             # Collection of utilities for controlling TCP/IP
      net-tools            # Network configuration tools (ifconfig, netstat)
      dnsutils             # DNS tools (dig, nslookup)

      # === CALCULATOR & CONVERSION ===
      bc                   # Arbitrary precision calculator
      units                # Unit conversion program

      # === MISCELLANEOUS ===
      pv                   # Monitor progress of data through pipe
      magic-wormhole       # Securely transfer files between computers
      asciinema            # Terminal session recorder
      # wordlists          # Common wordlists for security testing (broken — depends on wfuzz)
      seclists             # Security assessment wordlists collection

      # === METASPLOIT FRAMEWORK ===
      msfpc                # Msfvenom payload creator
      metasploit           # Metasploit framework

      # ============================================================
      # BINARY EXPLOITATION & PWN
      # ============================================================

      # === DEBUGGERS ===
      gdb                  # GNU Debugger
      lldb                 # LLVM debugger
      edb                  # Cross-platform AArch32/x86/x86-64 debugger

      # === GDB PLUGINS ===
      gef                  # GDB Enhanced Features

      # === DISASSEMBLERS & DECOMPILERS ===
      radare2              # Reverse engineering framework
      rizin                # Fork of radare2 with better structure
      cutter               # Free reverse engineering platform (GUI for rizin)
      iaito                # GUI for radare2
      ghidra               # NSA's software reverse engineering framework

      # === BINARY ANALYSIS ===
      (lib.lowPrio binutils)
      elfutils             # Utilities to handle ELF files
      patchelf             # Tool to modify ELF executables
      binwalk              # Firmware analysis tool
      pev                  # PE file analysis toolkit

      # === ROP & GADGET FINDING ===
      rp                   # ROP gadget finder (rp++)
      one_gadget           # Tool for finding one gadget RCE in libc
      pwninit              # Automate binary security challenge setup

      # === HEAP & LIBC ===
      glibc                # GNU C Library (for source reference)
      (lib.lowPrio musl)   # Lightweight C standard library

      # === ASSEMBLERS ===
      nasm                 # Netwide Assembler
      yasm                 # Rewrite of NASM

      # === COMPILERS & TOOLCHAINS ===
      gcc                  # GNU Compiler Collection

      # === FUZZING ===
      aflplusplus          # AFL++ fuzzer
      honggfuzz            # Security oriented fuzzer
      radamsa              # General purpose fuzzer

      # === DYNAMIC ANALYSIS ===
      strace               # System call tracer
      ltrace               # Library call tracer
      valgrind             # Memory debugging and profiling

      # === EMULATION ===
      qemu                 # Machine emulator and virtualizer
      unicorn              # Lightweight multi-platform CPU emulator framework

      # ============================================================
      # REVERSE ENGINEERING
      # ============================================================

      # === JAVA REVERSE ENGINEERING ===
      jadx                 # Dex to Java decompiler
      bytecode-viewer      # Java/Android reverse engineering suite

      # === .NET REVERSE ENGINEERING ===
      avalonia-ilspy       # Cross-platform .NET decompiler

      # === PYTHON REVERSE ENGINEERING ===
      pycdc                # Python bytecode disassembler

      # === MOBILE REVERSE ENGINEERING ===
      android-tools        # ADB and fastboot
      apktool              # Tool for reverse engineering Android APK files
      dex2jar              # Tools to work with Android .dex and .class files

      # === STRING & DATA EXTRACTION ===
      flare-floss          # FireEye Labs Obfuscated String Solver

      # === UNPACKING ===
      upx                  # Ultimate Packer for eXecutables

      # === PROTOCOL ANALYSIS ===
      protobuf             # Protocol Buffers compiler

      # === GAME HACKING ===
      scanmem              # Memory scanner for finding variables in games

      # ============================================================
      # FORENSICS
      # ============================================================

      # === DISK FORENSICS & DATA RECOVERY ===
      sleuthkit            # Collection of command line tools for digital forensics
      testdisk             # Data recovery software, works with partition tables
      foremost             # Console program to recover files based on headers/footers
      scalpel              # Fast file carver
      extundelete          # Utility to recover deleted files from ext3/ext4 partitions
      recoverjpeg          # Tool to recover JPEG images from a filesystem image
      magicrescue          # Recovers files by looking for magic bytes
      ddrescue             # Data recovery tool
      afflib               # Advanced Forensic Format library for disk images
      libewf               # Library to access the Expert Witness Compression Format

      # === PARTITION & FILESYSTEM TOOLS ===
      parted               # GNU partition editor
      gpart                # Tool to recover corrupted partition tables
      fatcat               # FAT filesystem exploration and recovery tool

      # === MEMORY FORENSICS ===
      volatility3          # Advanced memory forensics framework

      # === NETWORK FORENSICS ===
      wireshark            # Network protocol analyzer (GUI)
      (lib.lowPrio tshark) # Network protocol analyzer (CLI)
      tcpdump              # Command-line packet analyzer
      tcpflow              # TCP flow recorder
      ngrep                # Network packet analyzer
      ettercap             # Comprehensive suite for MITM attacks on LAN
      networkminer         # Network forensic analysis tool

      # === METADATA EXTRACTION ===
      exiftool             # Read and write meta information in files
      exifprobe            # Probe and report structure and metadata content

      # === PDF ANALYSIS ===
      pdf-parser           # Parse PDF files and extract various objects
      pdfid                # Tool to identify PDF files
      poppler-utils        # PDF rendering library utilities

      # === DOCUMENT FORENSICS ===
      odt2txt              # Simple converter from OpenDocument Text to plain text
      antiword             # Free MS Word document reader
      catdoc               # MS Office document reader

      # === WINDOWS FORENSICS ===
      regripper            # Tool for extracting info from Windows registry
      evtx                 # Windows Event Log parser

      # === SYSTEM FORENSICS ===
      yara                 # Pattern matching tool for malware researchers

      # === DATABASE FORENSICS ===
      sqlitebrowser        # Visual tool to create, design and edit SQLite databases

      # === HASHING & CHECKSUMS ===
      hashdeep             # Recursively compute hashsets and compare them
      ssdeep               # Fuzzy hashing tool to identify similar files

      # === DISK UTILITIES ===
      hdparm               # Get/set SATA/IDE device parameters
      smartmontools        # Tools to monitor hard drive health (SMART)
      dislocker            # For reading bitlocker encrypted images in linux

      # ============================================================
      # CRYPTOGRAPHY
      # ============================================================

      # === CRYPTOGRAPHIC LIBRARIES ===
      openssl              # Cryptographic library and toolkit
      (lib.lowPrio libressl) # LibreSSL cryptographic library
      gnutls               # GNU TLS library

      # === ENCRYPTION & DECRYPTION ===
      gnupg                # GNU Privacy Guard
      age                  # Simple, modern file encryption tool
      ccrypt               # Utility for encrypting and decrypting files

      # === HASH FUNCTIONS & CRACKING ===
      rhash                # Utility for computing hash sums
      hashcat              # Advanced password recovery utility
      hashcat-utils        # Utilities for Hashcat
      john                 # John the Ripper password cracker
      fcrackzip            # Password cracker for ZIP archives
      truecrack            # Password cracker for TrueCrypt volumes

      # === HASH IDENTIFICATION ===
      hashid               # Identify the different types of hashes
      hash-identifier      # Python tool to identify hash types

      # === CRYPTANALYSIS ===
      xortool              # Tool to analyze multi-byte XOR cipher

      # === RANDOM NUMBER GENERATION ===
      haveged              # Entropy harvesting daemon
      rng-tools            # Random number generator related utilities

      # === CERTIFICATE TOOLS ===
      certbot              # ACME client to obtain SSL/TLS certificates

      # === NUMBER THEORY & MATHEMATICS ===
      pari                 # Computer algebra system for number theory
      gap                  # System for computational discrete algebra

      # === SYMMETRIC ENCRYPTION ===
      aespipe              # AES encryption tool for tar/cpio

      # === BLOCKCHAIN ===
      bitcoin              # Bitcoin client (for crypto CTFs)

      # ============================================================
      # STEGANOGRAPHY
      # ============================================================

      imagemagick          # Image manipulation tools
      steghide             # Steganography program
      stegseek             # Lightning fast steghide cracker
      zsteg                # Detect stegano-hidden data in PNG and BMP
      outguess             # Universal steganographic tool

      # === QR CODES & BARCODES ===
      qrencode             # QR Code encoder
      zbar                 # QR Code/barcode scanner and decoder

      # ============================================================
      # WEB EXPLOITATION
      # ============================================================

      # === WEB PROXIES & INTERCEPTORS ===
      burpsuite            # Web application security testing tool
      zap                  # OWASP ZAP - Web application security scanner
      mitmproxy            # Interactive TLS-capable intercepting HTTP proxy

      # === WEB SCANNERS & RECONNAISSANCE ===
      nikto                # Web server scanner
      wpscan               # WordPress security scanner
      dirb                 # Web content scanner
      dirbuster            # Multi-threaded web directory brute-forcer
      gobuster             # Directory/file, DNS and VHost busting tool
      ffuf                 # Fast web fuzzer
      # wfuzz             # Web application fuzzer (broken in nixpkgs — pyparsing patch mismatch)
      feroxbuster          # Fast content discovery tool
      whatweb              # Web scanner to identify websites
      wafw00f              # Web Application Firewall detection tool

      # === SQL INJECTION ===
      sqlmap               # Automatic SQL injection and database takeover tool

      # === COMMAND INJECTION ===
      commix               # Command injection and exploitation tool

      # === CMS SCANNERS ===
      joomscan             # Joomla vulnerability scanner

      # === WEB SHELLS ===
      weevely              # Weaponized web shell

      # === SUBDOMAIN ENUMERATION ===
      amass                # In-depth attack surface mapping and asset discovery
      subfinder            # Subdomain discovery tool
      assetfinder          # Find domains and subdomains

      # === WEB FRAMEWORK TOOLS ===
      wapiti               # Web application vulnerability scanner
      nuclei               # Fast vulnerability scanner based on templates

      # === API TESTING ===
      postman              # API development and testing platform
      insomnia             # REST and GraphQL client
      httpie               # User-friendly HTTP client

      # === JWT TOOLS ===
      jwt-cli              # JSON Web Token command-line tool

      # === PARAMETER DISCOVERY ===
      arjun                # HTTP parameter discovery suite

      # === WORDLISTS ===
      seclists             # Collection of security assessment lists

      # === BROWSER AUTOMATION ===
      playwright           # Node.js library to automate browsers

      # === LOCAL WEB SERVERS ===
      php                  # For PHP built-in server

      # === TEXT BROWSERS ===
      lynx                 # Text-based web browser
      w3m                  # Text-based web browser
    ];
  };
}

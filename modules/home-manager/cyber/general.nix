# modules/home-manager/cyber/general-skills.nix
{ pkgs, lib, config, ... }: {
  options = {
    general.enable = 
      lib.mkEnableOption "Installs packages for general CTF and security skills";
  };
  
  config = lib.mkIf config.general.enable {
    home.packages = with pkgs; [
      
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
      
      # === FILE UTILITIES ===
      file                 # Determine file type
      fd                   # Simple, fast alternative to find
      ripgrep              # Fast search tool (better grep)
      tree                 # Display directory tree
      ncdu                 # NCurses disk usage analyzer
      
      # === JSON/XML PROCESSING ===
      jq                   # Command-line JSON processor
      yq                   # Command-line YAML/XML processor
      xmlstarlet           # Command-line XML toolkit
      
      # === STEGANOGRAPHY & IMAGES ===
      imagemagick          # Image manipulation tools
      exiftool             # Read/write meta information in files
      steghide             # Steganography program
      zsteg                # Detect stegano-hidden data in PNG/BMP
      stegseek             # Lightning fast steghide cracker
      
      # === QR CODES & BARCODES ===
      qrencode             # QR Code encoder
      zbar                 # QR Code/barcode scanner and decoder
      
      # === HASH & CHECKSUM ===
      hashcat              # Advanced password recovery utility
      
      # === WEB TOOLS ===
      httpie               # User-friendly HTTP client
      lynx                 # Text-based web browser
      w3m                  # Text-based web browser
      
      # === PROCESS MANAGEMENT ===
      htop                 # Interactive process viewer
      btop                 # Resource monitor
      lsof                 # List open files
      
      # === SYSTEM INFORMATION ===
      inxi                 # Full featured system information script
      
      # === NETWORKING UTILITIES ===
      iproute2             # Collection of utilities for controlling TCP/IP
      net-tools            # Network configuration tools (ifconfig, netstat)
      dnsutils             # DNS tools (dig, nslookup)
      
      # === CALCULATOR & CONVERSION ===
      bc                   # Arbitrary precision calculator
      units                # Unit conversion program
      
      # === HEX & BINARY VIEWERS ===
      hexdump              # Display file contents in hex
      xxd                  # Make a hexdump or reverse a hexdump
      hexyl                # Command-line hex viewer
      
      # === MISCELLANEOUS ===
      socat                # Multipurpose relay for bidirectional data transfer
      pv                   # Monitor progress of data through pipe
      magic-wormhole       # Securely transfer files between computers
      asciinema            # Terminal session recorder
    ];
  };
}

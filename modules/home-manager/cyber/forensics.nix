# modules/home-manager/cyber/forensics.nix
{ pkgs, lib, config, ... }: {
  options = {
    forensics.enable = 
      lib.mkEnableOption "Installs packages used for digital forensics analysis";
  };
  
  config = lib.mkIf config.forensics.enable {
    home.packages = with pkgs; [
      
      # === DISK FORENSICS & DATA RECOVERY ===
      autopsy              # Digital forensics platform and graphical interface to The Sleuth Kit
      sleuthkit            # Collection of command line tools for digital forensics
      testdisk             # Data recovery software, works with partition tables
      foremost             # Console program to recover files based on headers/footers
      scalpel              # Fast file carver that reads a database of header/footer definitions
      extundelete          # Utility to recover deleted files from ext3/ext4 partitions
      recoverjpeg          # Tool to recover JPEG images from a filesystem image
      magicrescue          # Recovers files by looking for magic bytes
      ddrescue             # Data recovery tool, copies data from one file/block device to another
      afflib               # Advanced Forensic Format library for disk images
      libewf               # Library to access the Expert Witness Compression Format
      
      # === PARTITION & FILESYSTEM TOOLS ===
      parted               # GNU partition editor
      gpart                # Tool to recover corrupted partition tables
      fatcat               # FAT filesystem exploration and recovery tool
      
      # === MEMORY FORENSICS ===
      volatility3          # Advanced memory forensics framework (Python 3 version)
      
      # === NETWORK FORENSICS & ANALYSIS ===
      wireshark            # Network protocol analyzer (GUI)
      (lib.lowPrio tshark) # Network protocol analyzer (CLI version of Wireshark)
      tcpdump              # Command-line packet analyzer
      tcpflow              # TCP flow recorder - captures data transmitted over TCP connections
      ngrep                # Network packet analyzer, like grep but for network traffic
      dsniff               # Collection of tools for network auditing and penetration testing
      ettercap             # Comprehensive suite for MITM attacks on LAN
      networkminer         # Network forensic analysis tool
      
      # === BINARY ANALYSIS TOOLS ===
      (lib.lowPrio binutils)
      binwalk              # Firmware analysis tool, searches binary images for embedded files
      elfutils             # Utilities to handle ELF object files
      pev                  # PE file analysis toolkit
      
      # === METADATA EXTRACTION ===
      exiftool             # Read and write meta information in files
      exifprobe            # Probe and report structure and metadata content of image files
      
      # === PDF ANALYSIS ===
      pdf-parser           # Parse PDF files and extract various objects
      pdfid                # Tool to identify PDF files with specific characteristics
      poppler-utils        # PDF rendering library utilities (pdfinfo, pdftotext, etc.)
      
      # === DOCUMENT FORENSICS ===
      odt2txt              # Simple converter from OpenDocument Text to plain text
      antiword             # Free MS Word document reader
      catdoc               # MS Office document reader (Word, Excel, PowerPoint)
      
      # === ARCHIVE EXTRACTION ===
      cabextract           # Program to extract Microsoft cabinet (.CAB) files
      p7zip                # Port of 7-Zip archiver
      unzip                # De-archiver for .zip files
      unrar                # Utility for RAR archives
      
      # === WINDOWS FORENSICS ===
      regripper            # Tool for extracting info from Windows registry
      
      # === SYSTEM FORENSICS ===
      yara                 # Pattern matching tool for malware researchers
      
      # === MOBILE FORENSICS ===
      android-tools        # Android platform tools (adb, fastboot)
      
      # === STEGANOGRAPHY ===
      steghide             # Steganography program
      stegseek             # Lightning fast steghide cracker
      zsteg                # Detect stegano-hidden data in PNG and BMP files
      outguess             # Universal steganographic tool
      
      # === DATABASE FORENSICS ===
      sqlitebrowser        # Visual tool to create, design and edit SQLite databases
      
      # === FILE IDENTIFICATION & HEX EDITING ===
      file                 # File type identification utility
      hexedit              # View and edit files in hexadecimal or ASCII
      xxd                  # Make a hexdump or reverse a hexdump
      
      # === HASHING & CHECKSUMS ===
      hashdeep             # Recursively compute hashsets and compare them
      ssdeep               # Fuzzy hashing tool to identify similar files
      
      # === PASSWORD CRACKING ===
      hashcat              # Advanced password recovery utility
      john                 # John the Ripper password cracker
      fcrackzip            # Password cracker for ZIP archives
      truecrack            # Password cracker for TrueCrypt volumes
      
      # === DISK UTILITIES ===
      hdparm               # Get/set SATA/IDE device parameters
      smartmontools        # Tools to monitor hard drive health (SMART)
      
      # === DEBUGGING & TRACING ===
      strace               # System call tracer for Linux
      ltrace               # Library call tracer
      valgrind             # Instrumentation framework for memory debugging
      gdb                  # GNU Debugger
      
      # === REVERSE ENGINEERING (Forensics-related) ===
      radare2              # Reverse engineering framework
      ghidra               # NSA's software reverse engineering framework
      bytecode-viewer      # Java/Android reverse engineering suite
      apktool              # Tool for reverse engineering Android APK files
      upx                  # Ultimate Packer for eXecutables
      nasm                 # Netwide Assembler
    ];
  };
}

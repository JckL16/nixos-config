# modules/home-manager/cyber/reverse-engineering.nix
{ pkgs, lib, config, ... }: {
  options = {
    reverse-engineering.enable = 
      lib.mkEnableOption "Installs packages used for reverse engineering";
  };
  
  config = lib.mkIf config.reverse-engineering.enable {
    home.packages = with pkgs; [
      
      # === DISASSEMBLERS & DECOMPILERS ===
      ghidra               # NSA's software reverse engineering framework
      ida-free             # IDA Free version (if available)
      radare2              # Reverse engineering framework
      rizin                # Fork of radare2 with better structure
      cutter               # Free reverse engineering platform (GUI for rizin)
      iaito                # GUI for radare2
      hopper               # Reverse engineering tool (if available)
      
      # === DEBUGGERS ===
      gdb                  # GNU Debugger
      gef                  # GDB Enhanced Features (if available as package)
      #TODO fix this dependency
      # pwndbg               # GDB plugin for exploit development (if available)
      lldb                 # LLVM debugger
      edb                  # Cross-platform AArch32/x86/x86-64 debugger
      
      # === BINARY ANALYSIS ===
      binutils             # Collection of binary tools
      elfutils             # Utilities to handle ELF files
      patchelf             # Tool to modify ELF executables and libraries
      checksec             # Check binary security properties
      pwninit              # Automate binary security challenge setup
      one_gadget           # Tool for finding one gadget RCE
      
      # === JAVA REVERSE ENGINEERING ===
      jadx                 # Dex to Java decompiler
      apktool              # Tool for reverse engineering Android APK files
      bytecode-viewer      # Java/Android reverse engineering suite
      
      # === .NET REVERSE ENGINEERING ===
      avalonia-ilspy       # Cross-platform .NET decompiler
      
      # === PYTHON REVERSE ENGINEERING ===
      pycdc                # Python bytecode disassembler
      
      # === MOBILE REVERSE ENGINEERING ===
      android-tools        # ADB and fastboot
      apktool              # Android APK reverse engineering
      dex2jar              # Tools to work with Android .dex and .class files
      
      # === FIRMWARE ANALYSIS ===
      binwalk              # Firmware analysis tool
      
      # === STRING & DATA EXTRACTION ===
      flare-floss          # FireEye Labs Obfuscated String Solver
      
      # === UNPACKING & DEOBFUSCATION ===
      upx                  # Ultimate Packer for eXecutables
      
      # === PROTOCOL REVERSE ENGINEERING ===
      wireshark            # Network protocol analyzer
      protobuf             # Protocol Buffers compiler
      
      # === DYNAMIC ANALYSIS ===
      ltrace               # Library call tracer
      strace               # System call tracer
      valgrind             # Instrumentation framework for building dynamic analysis tools
      
      # === EMULATION & VIRTUALIZATION ===
      qemu                 # Generic machine emulator and virtualizer
      unicorn              # Lightweight multi-platform CPU emulator framework
      
      # === SCRIPTING FOR REVERSE ENGINEERING ===
      python3              # Python interpreter for scripting
      python3Packages.pwntools       # CTF framework and exploit development library
      python3Packages.capstone       # Disassembly framework
      python3Packages.keystone-engine # Assembler framework
      python3Packages.unicorn        # CPU emulator framework
      python3Packages.r2pipe         # Pipe interface for radare2
      
      # === WINDOWS PE ANALYSIS ===
      pev                  # PE file analysis toolkit
      
      # === ASSEMBLY & DISASSEMBLY ===
      nasm                 # Netwide Assembler
      yasm                 # Rewrite of NASM assembler
      
      # === GAME HACKING ===
      scanmem              # Memory scanner for finding variables in games
      
      # === MISCELLANEOUS ===
      hexedit              # View and edit files in hexadecimal
      xxd                  # Make a hexdump or reverse a hexdump
      imhex                # High quality hex editor
      ghex                 # ------ || ------
      hexcurse             # Ncurses-based hex editor
      file                 # Determine file type
      glibc                # Includes ldd 
      binutils             # Includes objdump, nm, readelf and strings to name a few
    ];
  };
}

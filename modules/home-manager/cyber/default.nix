{ pkgs, lib, config, ... }:
let
  extractArchive = pkgs.writeShellScriptBin "spf-extract-archive" ''
    set -e
    f="$1"
    dir="$(dirname "$f")"
    base="$(basename "$f")"
    name="''${base%.*}"
    [[ "$name" == *.tar ]] && name="''${name%.tar}"
    dest="$dir/$name"
    mkdir -p "$dest"
    case "$f" in
      *.tar.gz|*.tgz) tar -xzf "$f" -C "$dest" ;;
      *.tar.bz2|*.tbz2) tar -xjf "$f" -C "$dest" ;;
      *.tar) tar -xf "$f" -C "$dest" ;;
      *.gz) gunzip -k -c "$f" > "$dest/''${name}" ;;
      *.zip) unzip -o "$f" -d "$dest" ;;
      *.7z) 7z x -o"$dest" "$f" ;;
      *.rar) unrar x "$f" "$dest/" ;;
      *) echo "Unsupported archive: $f"; exit 1 ;;
    esac
    notify-send "Archive extracted" "$dest"
  '';
in {
  options = {
    cyber.enable =
      lib.mkEnableOption "Enable comprehensive cyber security toolkit";
  };

  config = lib.mkIf config.cyber.enable {
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

      cyberchef

      ruby
      perl
      bash

      netcat
      nmap
      masscan
      rustscan
      traceroute
      mtr
      whois
      host
      socat

      openssh
      sshpass
      sshfs

      samba

      rsync
      curl
      wget
      aria2

      zip
      unzip
      gzip
      bzip2
      xz
      p7zip
      unrar
      cabextract

      file
      fd
      ripgrep
      tree
      ncdu

      jq
      yq
      xmlstarlet
      htmlq
      pup

      xxd
      hexdump
      hexyl
      hexedit
      imhex
      ghex

      htop
      btop
      lsof
      inxi
      iproute2
      net-tools
      dnsutils

      bc
      units

      pv
      magic-wormhole
      asciinema
      wordlists

      msfpc
      metasploit

      gdb
      lldb
      edb

      gef

      radare2
      rizin
      cutter
      ghidra

      (lib.lowPrio binutils)
      elfutils
      patchelf
      binwalk
      pev

      rp
      one_gadget
      pwninit

      glibc
      (lib.lowPrio musl)

      nasm
      yasm

      gcc

      aflplusplus
      honggfuzz
      radamsa

      strace
      ltrace
      valgrind

      qemu
      unicorn

      jadx
      bytecode-viewer

      avalonia-ilspy

      pycdc

      android-tools
      apktool
      dex2jar

      flare-floss

      upx

      protobuf

      scanmem

      libguestfs-with-appliance
      sleuthkit
      autopsy
      testdisk
      foremost
      scalpel
      extundelete
      recoverjpeg
      magicrescue
      ddrescue
      afflib
      libewf

      parted
      gpart
      fatcat

      volatility3

      wireshark
      (lib.lowPrio tshark)
      tcpdump
      tcpflow
      ngrep
      ettercap
      networkminer

      exiftool
      exifprobe

      pdf-parser
      pdfid
      poppler-utils

      odt2txt
      antiword
      catdoc

      regripper
      evtx

      yara

      sqlitebrowser

      hashdeep
      ssdeep

      hdparm
      smartmontools
      dislocker

      openssl
      (lib.lowPrio libressl)
      gnutls

      gnupg
      age
      ccrypt

      rhash
      hashcat
      hashcat-utils
      john
      thc-hydra
      fcrackzip
      truecrack

      hashid
      hash-identifier

      xortool

      haveged
      rng-tools

      certbot

      pari
      gap

      aespipe

      bitcoin

      imagemagick
      steghide
      stegseek
      zsteg
      outguess

      qrencode
      zbar

      burpsuite
      zap
      mitmproxy

      nikto
      wpscan
      dirb
      dirbuster
      gobuster
      ffuf
      wfuzz
      feroxbuster
      whatweb
      wafw00f

      sqlmap

      commix

      joomscan

      weevely

      amass
      subfinder
      assetfinder

      nuclei

      postman
      insomnia
      httpie

      jwt-cli

      gitleaks
      trufflehog

      arjun

      seclists

      playwright

      php

      lynx
      w3m

      gnuradio
      inspectrum
      urh
      sox
      audacity

      ffmpeg
      vlc

      extractArchive
    ];

    xdg.desktopEntries.spf-extract-archive = {
      name = "Extract Archive";
      exec = "kitty --class archive-extract ${extractArchive}/bin/spf-extract-archive %f";
      terminal = false;
      type = "Application";
      categories = [ "Utility" "Archiving" ];
      mimeType = [
        "application/zip"
        "application/x-7z-compressed"
        "application/x-tar"
        "application/gzip"
        "application/vnd.rar"
        "application/x-rar-compressed"
      ];
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/zip" = "spf-extract-archive.desktop";
        "application/x-7z-compressed" = "spf-extract-archive.desktop";
        "application/x-tar" = "spf-extract-archive.desktop";
        "application/gzip" = "spf-extract-archive.desktop";
        "application/vnd.rar" = "spf-extract-archive.desktop";
        "application/x-rar-compressed" = "spf-extract-archive.desktop";
        "audio/mpeg" = "vlc.desktop";
        "audio/mp3" = "vlc.desktop";
        "audio/flac" = "vlc.desktop";
        "audio/ogg" = "vlc.desktop";
        "audio/wav" = "vlc.desktop";
        "audio/x-wav" = "vlc.desktop";
        "audio/aac" = "vlc.desktop";
        "audio/m4a" = "vlc.desktop";
        "audio/x-m4a" = "vlc.desktop";
        "video/mp4" = "vlc.desktop";
        "video/x-matroska" = "vlc.desktop";
        "video/webm" = "vlc.desktop";
        "video/avi" = "vlc.desktop";
        "video/x-msvideo" = "vlc.desktop";
        "video/quicktime" = "vlc.desktop";
      };
    };
  };
}

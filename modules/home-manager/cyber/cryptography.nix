# modules/home-manager/cyber/cryptography.nix
{ pkgs, lib, config, ... }: {
  options = {
    cryptography.enable = 
      lib.mkEnableOption "Installs packages used for cryptography and cryptanalysis";
  };
  
  config = lib.mkIf config.cryptography.enable {
    home.packages = with pkgs; [
      
      # === CRYPTOGRAPHIC LIBRARIES & TOOLS ===
      openssl              # Cryptographic library and toolkit
      (lib.lowPrio libressl) # LibreSSL cryptographic library
      gnutls               # GNU TLS library
      
      # === ENCRYPTION & DECRYPTION ===
      gnupg                # GNU Privacy Guard - encryption and signing tool
      age                  # Simple, modern file encryption tool
      ccrypt               # Utility for encrypting and decrypting files and streams
      
      # === HASH FUNCTIONS ===
      rhash                # Utility for computing hash sums and magnet links
      hashcat              # Advanced password recovery utility
      hashcat-utils        # Utilities for Hashcat
      john                 # John the Ripper password cracker
      
      # === HASH CRACKING UTILITIES ===
      hashid               # Identify the different types of hashes
      hash-identifier      # Python tool to identify hash types
      
      # === CRYPTANALYSIS TOOLS ===
      xortool              # Tool to analyze multi-byte XOR cipher
      
      # === STEGANOGRAPHY (Crypto-related) ===
      steghide             # Steganography program
      stegseek             # Lightning fast steghide cracker
      outguess             # Universal steganographic tool
      zsteg                # Detect stegano-hidden data in PNG and BMP
      
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
      mcrypt               # Replacement for crypt(1)
      
      # === BLOCKCHAIN & CRYPTOCURRENCY ===
      bitcoin              # Bitcoin client (if doing crypto CTFs)
      
      # === MISCELLANEOUS ===
      qrencode             # QR Code encoder
      zbar                 # QR Code/barcode scanner
      asciinema            # Terminal session recorder (for demonstrations)
    ];
  };
}

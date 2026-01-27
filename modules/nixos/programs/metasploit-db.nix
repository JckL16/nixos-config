# modules/nixos/programs/metasploit-db.nix

{ pkgs, lib, config, variables, ... }: {
  options = {
    metasploit-db.enable =
      lib.mkEnableOption "Enable PostgreSQL database for Metasploit Framework";
  };

  config = lib.mkIf config.metasploit-db.enable {
    # Enable PostgreSQL
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;

      # Create msf database and user
      ensureDatabases = [ "msf" ];
      ensureUsers = [
        {
          name = "msf";
          ensureDBOwnership = true;
        }
      ];

      # Allow local connections with peer authentication (more secure than trust)
      authentication = lib.mkOverride 10 ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             all                                     peer
        host    all             all             127.0.0.1/32            scram-sha-256
        host    all             all             ::1/128                 scram-sha-256
      '';
    };

    # Create the database.yml config for Metasploit in user's home
    system.activationScripts.metasploit-db-config = ''
      MSF_DIR="/home/${variables.username}/.msf4"
      DB_CONFIG="$MSF_DIR/database.yml"

      mkdir -p "$MSF_DIR"

      if [ ! -f "$DB_CONFIG" ]; then
        cat > "$DB_CONFIG" << 'EOF'
production:
  adapter: postgresql
  database: msf
  username: msf
  host: localhost
  port: 5432
  pool: 5
  timeout: 5
EOF
        chown -R ${variables.username}:users "$MSF_DIR"
      fi
    '';
  };
}

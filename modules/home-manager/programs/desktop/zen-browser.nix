{ config, inputs, ... }:
let
  c = config.theme.colors;
in {
  imports = [ inputs.zen-browser.homeModules.beta ];

  config = {
    # Let home-manager take ownership of profiles.ini even on a machine that
    # already had a non-declarative Zen/Firefox install — it would otherwise
    # refuse to clobber the pre-existing file. No effect on a fresh install
    # (nothing to overwrite). Per-host profile `path`/`name` overrides (see
    # e.g. hosts/nixos-rugged/home.nix) point the declarative profile at the
    # existing profile directory so real browsing data isn't orphaned.
    home.file."${config.xdg.configHome}/zen/profiles.ini".force = true;

    programs.zen-browser = {
      setAsDefaultBrowser = true;

      # Firefox-based browsers refuse to load chrome/userChrome.css at all
      # unless this is explicitly enabled — without it the file above is
      # just inert, no matter how correct its content is.
      profiles.default.settings."toolkit.legacyUserProfileCustomizations.stylesheets" = true;

      # A WebExtension theme (e.g. an installed "Gruvbox"/"Nord" add-on theme)
      # uses Firefox's native theme API and wins over userChrome.css for the
      # chrome slots it defines, making the CSS above look like it's not
      # applying at all. Pinning this to the built-in default theme every
      # startup ensures userChrome.css is the only thing drawing the chrome.
      profiles.default.settings."extensions.activeThemeID" = "default-theme@mozilla.org";

      # Zen's own CSS custom properties (verified against the tinted-zen
      # community template: github.com/tinted-theming/tinted-zen) mapped onto
      # theme.colors so the browser chrome tracks variables.theme like every
      # other themed app in this config.
      profiles.default.userChrome = ''
        * {
          --base:       ${c.background};
          --surface:    ${c.backgroundAlt};
          --overlay:    ${c.surface};
          --muted:      ${c.border};
          --subtle:     ${c.textDim};
          --text:       ${c.text};
          --bright:     ${c.textBright};
          --secondary:  ${c.accentBlue};
          --primary:    ${c.accent};
          --on-primary: ${c.background};
        }

        :root {
          /* --- Core Zen accent --- */
          --zen-primary-color:                      var(--primary) !important;
          --zen-colors-primary:                     var(--surface) !important;
          --zen-colors-secondary:                   var(--surface) !important;
          --zen-colors-tertiary:                    var(--surface) !important;
          --zen-colors-hover-bg:                     var(--overlay) !important;
          --zen-colors-primary-foreground:           var(--text) !important;
          --zen-colors-border:                       var(--primary) !important;
          --zen-colors-border-contrast:               var(--subtle) !important;
          --zen-colors-input-bg:                      var(--surface) !important;

          /* --- Backgrounds --- */
          --zen-main-browser-background:             var(--base) !important;
          --zen-dialog-background:                    var(--overlay) !important;
          --zen-themed-toolbar-bg:                    var(--surface) !important;
          --zen-themed-toolbar-bg-transparent:        transparent !important;
          --zen-urlbar-background:                    var(--surface) !important;
          --zen-branding-dark:                        var(--base) !important;
          --zen-branding-paper:                       var(--bright) !important;

          /* --- Sidebar --- */
          --zen-sidebar-notification-bg:              var(--primary) !important;
          --zen-sidebar-themed-icon-fill:              var(--text) !important;
          --zen-appcontent-border:                     1px solid var(--overlay) !important;

          /* --- Toolbar / Firefox standard --- */
          --toolbar-bgcolor:                          var(--surface) !important;
          --toolbar-color:                            var(--text) !important;
          --toolbox-bgcolor-inactive:                  var(--surface) !important;
          --toolbox-textcolor:                        var(--text) !important;
          --toolbox-textcolor-inactive:                var(--text) !important;
          --toolbarbutton-icon-fill:                   var(--primary) !important;
          --toolbarbutton-hover-background:            var(--overlay) !important;
          --toolbarbutton-active-background:           var(--muted) !important;

          /* --- URL bar --- */
          --urlbar-box-bgcolor:                       var(--surface) !important;
          --urlbar-box-hover-bgcolor:                  var(--overlay) !important;
          --urlbar-box-focus-bgcolor:                  var(--surface) !important;
          --urlbar-box-text-color:                     var(--text) !important;
          --toolbar-field-color:                       var(--text) !important;
          --toolbar-field-focus-color:                 var(--text) !important;

          /* --- Tabs --- */
          --tab-selected-bgcolor:                      var(--overlay) !important;
          --tab-selected-color:                        var(--text) !important;
          --tab-selected-textcolor:                    var(--primary) !important;

          /* --- Popups & menus --- */
          --arrowpanel-background:                     var(--overlay) !important;
          --arrowpanel-color:                          var(--text) !important;
          --arrowpanel-border-color:                   var(--overlay) !important;

          /* --- Sidebar / LWT --- */
          --sidebar-text-color:                        var(--text) !important;
          --lwt-sidebar-text-color:                    var(--text) !important;
          --lwt-sidebar-background-color:              var(--surface) !important;
          --lwt-text-color:                            var(--text) !important;

          /* --- New tab page --- */
          --newtab-background-color:                   var(--overlay) !important;
          --newtab-text-primary-color:                 var(--text) !important;
        }

        /* --- Sidebar & layout --- */

        #navigator-toolbox,
        #zen-tabbox-wrapper,
        .sidebar-panel {
          background-color: var(--surface) !important;
        }

        #zen-sidebar-splitter {
          background-color: var(--surface) !important;
          opacity: 1 !important;
        }

        .sidebar-placesTree {
          background-color: var(--surface) !important;
        }

        #zen-workspaces-button {
          background-color: var(--surface) !important;
        }

        #zen-appcontent-navbar-container {
          background-color: var(--surface) !important;
        }

        #TabsToolbar {
          background-color: var(--surface) !important;
        }

        hbox#titlebar {
          background-color: var(--surface) !important;
        }

        /* --- Navigation controls --- */

        #back-button .toolbarbutton-icon,
        #forward-button .toolbarbutton-icon,
        #reload-button .toolbarbutton-icon,
        #stop-button .toolbarbutton-icon,
        #PanelUI-menu-button .toolbarbutton-icon,
        #unified-extensions-button .toolbarbutton-icon,
        #nav-bar-overflow-button .toolbarbutton-icon,
        #zen-toggle-compact-mode .toolbarbutton-icon {
          fill: var(--primary) !important;
          color: var(--primary) !important;
        }

        #back-button[disabled] .toolbarbutton-icon,
        #forward-button[disabled] .toolbarbutton-icon {
          opacity: 0.3 !important;
        }

        toolbarbutton#tabs-newtab-button {
          color: var(--text) !important;
        }

        /* --- Tabs --- */

        .tab-text {
          color: var(--text);
        }

        .tab-background[selected=""] {
          background: var(--overlay) !important;
        }

        /* --- URL bar --- */

        #urlbar-input {
          color: var(--text) !important;
        }

        #urlbar-input::selection {
          background-color: var(--primary) !important;
          color: var(--on-primary) !important;
        }

        .urlbar-background,
        #urlbar-input-container {
          background-color: var(--base) !important;
        }

        .urlbarView-url {
          color: var(--primary) !important;
        }

        .urlbarView-favicon {
          background-color: var(--base) !important;
        }

        #urlbar-results {
          background-color: var(--overlay) !important;
          color: var(--text) !important;
        }

        .urlbarView-row:not([selected]) :is(.urlbarView-title, .urlbarView-action) {
          color: var(--text) !important;
        }

        /* --- UI components --- */

        .content-shortcuts {
          background-color: var(--surface) !important;
          border-color: var(--secondary) !important;
        }

        #zenEditBookmarkPanelFaviconContainer {
          background: var(--base) !important;
        }

        #zen-toast-container {
          color: var(--primary) !important;
        }

        #PanelUI-menu-button[open] .toolbarbutton-icon {
          fill: var(--primary) !important;
        }

        #permissions-granted-icon {
          color: var(--base) !important;
        }

        /* --- Workspace indicator --- */

        .zen-current-workspace-indicator-name {
          color: var(--text);
        }

        .zen-current-workspace-indicator-icon {
          fill: var(--text) !important;
        }
      '';
    };

    home.sessionVariables = {
      MOZ_ENABLE_WAYLAND = "1";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "application/pdf" = "zen-beta.desktop";
      };
    };
  };
}

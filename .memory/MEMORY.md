# Memory Index

- [feedback_no_coauthor.md](feedback_no_coauthor.md) — Never add Co-Authored-By Claude to git commits
- [feedback_no_nix_commands.md](feedback_no_nix_commands.md) — Never run nix/nixos-rebuild commands; tell user what to run instead
- [feedback_ask_before_git.md](feedback_ask_before_git.md) — Always ask before git commit or push
- [project_nixos_config.md](project_nixos_config.md) — Non-obvious decisions and constraints in the NixOS flake config repo (LUKS/boot)
- [project_host_purposes.md](project_host_purposes.md) — What each host is for and host-specific non-obvious context
- [project_install_quirks.md](project_install_quirks.md) — Installation gotchas: RAM exhaustion, LUKS password, disko, monitor setup
- [project_hyprpanel.md](project_hyprpanel.md) — Non-obvious HyprPanel config decisions: ELOOP fix, monochrome requirement, udiskie tray, blueman, CSS constraints
- [project_walker.md](project_walker.md) — Walker launcher: -V flag quirks, clipboard awk workaround, theme copy requirement, hicolor SVG icons
- [feedback_use_web_search.md](feedback_use_web_search.md) — Use web search for package behaviour research, not nix store inspection or binary execution
- [project_mesa_workaround.md](project_mesa_workaround.md) — Temporary RADV_DEBUG=nogpl in amd.nix for Mesa 26.1.2 Unity crash — remove once Mesa 26.1.3+ ships
- [feedback_prefer_existing_nix_modules.md](feedback_prefer_existing_nix_modules.md) — Search for an official nixpkgs/home-manager module before hand-rolling a derivation
- [project_serpantinum_bar_fork.md](project_serpantinum_bar_fork.md) — In-progress fork of Serpantinum's bar+power-menu replacing HyprPanel/wlogout; pinned commit, plan file location
- [project_theme_monochrome_todo.md](project_theme_monochrome_todo.md) — Monochrome theme done: base16 Grayscale Dark palette choice, tradeoffs, where to adjust
- [project_quickshell_hyprland_gotchas.md](project_quickshell_hyprland_gotchas.md) — Verified QuickShell/Qt6 API, Hyprland portal/windowrule, and EDS calendar gotchas (code comments were stripped, moved here)
- [project_nvim_cpp_tooling.md](project_nvim_cpp_tooling.md) — How nvim's auto compile_commands.json generation works (build-root/project-root scoping, merge-not-overwrite for CMake)

---
name: project-nvim-cpp-tooling
description: How the automatic compile_commands.json generation in nvim's C/C++ setup works and why it's built the way it is
metadata:
  type: project
---

`modules/home-manager/programs/command-line/nvim/default.nix`'s `extraConfigLua` includes a
custom system (triggered from a `FileType` autocmd for `c`/`cpp`) that auto-generates
`compile_commands.json` so clangd/LSP has accurate compile flags, for both Makefile- and
CMake-based projects, without requiring the user to remember to run `bear`/`cmake` manually.

**Build root detection:** `find_build_root` walks upward from the current file for the nearest
`Makefile`/`makefile`/`CMakeLists.txt`; `find_project_root` then walks upward from *that* for the
nearest `.git`, falling back to the build root itself if no `.git` is found. Scoping the
"does a compile_commands.json already exist" check to the **project root** (not just the build
root) means generating one at any level (e.g. a sub-project) stops further prompts for
sibling/parent build files in the same project — without this, a monorepo-style layout with
multiple Makefiles would re-prompt for every nested one.

**Why merge instead of overwrite:** For CMake specifically, each generation runs in its own
build directory, so naively re-running would only cover that one subdirectory's build and
overwrite whatever a sibling subdirectory's build had already produced. `merge_compile_commands`
merges the new file's entries into the existing one, deduping by `file + directory`, so builds in
different subdirectories (e.g. separate tutorial/exercise projects sharing one repo) accumulate
into one project-wide `compile_commands.json` instead of clobbering each other. Bear doesn't need
this — it has a native `--append` mode — so this merge step only runs for CMake.

**Trigger modes:**
- *Automatic*: fires once per project per session (tracked in `bear_checked_projects`), only
  offers to run if no `compile_commands.json` exists anywhere in the project yet.
- *Manual*: can be run any time, targets the build file nearest the current file regardless of
  whether a `compile_commands.json` already exists — for regenerating after adding new files.

**Why this matters if editing:** The project-root-scoping and merge-not-overwrite behavior are
both there specifically to support multi-subdirectory C/C++ course/practice repos (the coursework
this was built for) where naive per-directory regeneration would keep destroying siblings' data.
Don't "simplify" this back to a flat overwrite without checking whether that use case still
applies.

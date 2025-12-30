# Modular Dotfiles Setup

This project has been refactored into a modular structure to support different platforms and functional requirements.

## Structure

- `setup`: The main entry point script.
- `config.sh`: Configuration file to enable/disable modules based on platform or preference.
- `lib/`: Shared utility functions (e.g., symlinking).
- `modules/`: Functional modules:
  - `links.sh`: Handles symlinking of dotfiles and scripts.
  - `apt.sh`: Handles Debian/Ubuntu package installation.
  - `tools.sh`: Handles custom tools like `yank` and `zoxide`.

## How to use

### Basic usage
Run the setup script:
```bash
./setup
```

### Custom configuration
You can create a custom configuration file and pass it as an argument:
```bash
./setup my_config.sh
```

### Adding a new module
1. Create a new script in `modules/your_module.sh`.
2. Define a `run_module()` function in it.
3. Add `your_module` to the `MODULES` array in `config.sh`.

## Platform Support
The default `config.sh` uses `uname -s` to detect the operating system and adjust the `MODULES` list accordingly. You can easily extend this to support more platforms (e.g., macOS with Homebrew).

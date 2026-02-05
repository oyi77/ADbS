# Termux & Mobile Development Guide

ADbS runs natively on mobile devices via Termux (Android) and iSH (iOS).

## 📱 Termux (Android)

### Installation

1. **Install Termux** from [F-Droid](https://f-droid.org/packages/com.termux/) (recommended over Play Store version)

2. **Install ADbS**:
   ```bash
   curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install-termux.sh | bash
   ```

3. **Restart Termux** or source your profile:
   ```bash
   source ~/.termux/bashrc
   ```

### Manual Installation

If you prefer manual installation:

```bash
# Create installation directory
mkdir -p ~/.local/bin

# Download binary for ARM64 (most common)
cd ~/.local/bin
curl -sSL https://github.com/oyi77/ADbS/releases/latest/download/adbs-linux-arm64 -o adbs
chmod +x adbs

# Add to PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.termux/bashrc
source ~/.termux/bashrc
```

### Supported Architectures

| Device | Architecture | Binary |
|--------|-------------|--------|
| Most phones (Pixel, Samsung, etc.) | ARM64 | `adbs-linux-arm64` |
| Older devices | ARMv7 | `adbs-linux-arm` |
| x86 emulators | i386 | `adbs-linux-386` |

### First Steps in Termux

```bash
# Verify installation
adbs help

# Initialize in your project
cd ~/projects/my-app
adbs setup

# Start working
adbs new "Add dark mode"

# Check status
adbs status

# Add tasks
adbs todo "Design color scheme"
adbs todo "Implement CSS"
```

---

## 🍎 iSH (iOS)

### Installation

1. **Install iSH** from the [App Store](https://apps.apple.com/us/app/ish-shell/id1436902233)

2. **Install required packages**:
   ```bash
   apk update
   apk add curl wget
   ```

3. **Download the Linux ARM64 binary**:
   ```bash
   cd ~
   wget https://github.com/oyi77/ADbS/releases/latest/download/adbs-linux-arm64 -O adbs
   chmod +x adbs
   ```

4. **Run ADbS**:
   ```bash
   ./adbs help
   ```

### Note on iSH
iSH runs Linux in userspace, so there may be some limitations. For best results on iOS, consider:
- Using SSH to connect to a remote Linux server
- Using a web-based dashboard if available

---

## 🔧 Troubleshooting

### "Command not found" after installation

1. Check if the binary is in your PATH:
   ```bash
   echo $PATH
   ls -la ~/.local/bin/adbs
   ```

2. If not found, manually add to PATH:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. Make binary executable:
   ```bash
   chmod +x ~/.local/bin/adbs
   ```

### Permission denied

```bash
# Make sure the binary is executable
chmod +x ~/.local/bin/adbs
```

### Binary doesn't run

1. Check architecture:
   ```bash
   uname -m
   ```

2. Download the correct binary for your architecture from [Releases](https://github.com/oyi77/ADbS/releases)

---

## 📱 Mobile Workflow Tips

### Limited Screen Space
- Use `adbs status` for quick overview
- Use `adbs list` to see all work items
- Generate dashboard: `adbs dashboard` (opens in browser)

### Battery Considerations
- ADbS is lightweight and won't drain battery
- Use `adbs done` to archive completed work

### Offline Usage
- ADbS works completely offline
- No internet required after installation
- All data stored locally

---

## 🔄 Updating ADbS

To update to the latest version:

```bash
# Re-run the installer
curl -sSL https://raw.githubusercontent.com/oyi77/ADbS/main/distribution/install-termux.sh | bash
```

Or manually:

```bash
cd ~/.local/bin
wget https://github.com/oyi77/ADbS/releases/latest/download/adbs-linux-arm64 -O adbs
chmod +x adbs
```

---

## 📞 Support

- **GitHub Issues**: [Report bugs](https://github.com/oyi77/ADbS/issues)
- **Discussions**: [Ask questions](https://github.com/oyi77/ADbS/discussions)

---

**Happy coding on mobile! 📱💻**

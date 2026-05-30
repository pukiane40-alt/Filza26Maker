# Filza26Maker

**v2.1** — Convert Filza File Manager `.deb` → `.ipa` for **iOS 17 / 18 / 26** (jailed sideload)

Works on Linux, macOS, and Windows Subsystem for Linux (WSL).

---

## Two Modes

### Mode A — Use pre-built Premium IPA (fastest)
A ready-to-sign Premium IPA is included in this repo.

```bash
bash Filza26Maker.sh Filza-Jailed-iOS26-Premium.ipa
```

The IPA is copied to your Desktop (WSL) or current directory (Linux/macOS).

---

### Mode B — Build from .deb (original method)

Download and convert the official Filza `.deb` automatically:

```bash
bash Filza26Maker.sh
```

Or provide a local `.deb` file:

```bash
bash Filza26Maker.sh /path/to/filza.deb
```

---

## Requirements (Mode B only)

```bash
# Ubuntu / WSL
sudo apt update && sudo apt install -y curl binutils tar zip

# macOS (Homebrew)
brew install gnu-ar
```

---

## Installation (WSL — Windows)

```powershell
# 1. Install WSL (PowerShell as Admin)
wsl --install -d Ubuntu

# 2. Inside Ubuntu terminal:
sudo apt update && sudo apt install -y curl binutils tar zip

# 3. Run
bash Filza26Maker.sh Filza-Jailed-iOS26-Premium.ipa
```

---

## After getting the IPA

Sign and install with one of:
- **[Sideloadly](https://sideloadly.io)** (Windows/macOS)
- **[AltStore](https://altstore.io)**
- **ESign** (on-device)

---

## License
Apache 2.0 — see [LICENSE](LICENSE)

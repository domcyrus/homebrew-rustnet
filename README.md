# Homebrew RustNet

Homebrew tap for [RustNet](https://github.com/domcyrus/rustnet) - a real-time, cross-platform network monitoring terminal UI tool built with Rust.

## About RustNet

RustNet is a powerful network monitoring tool that provides:

- **Real-time monitoring** of TCP, UDP, ICMP, and ARP connections
- **Deep Packet Inspection (DPI)** for detecting application protocols  
- **Process identification** and service name resolution
- **Cross-platform support** (Linux, macOS)
- **Responsive terminal UI** for interactive network analysis
- **Multi-threaded architecture** for efficient packet processing

## Installation

```bash
brew tap domcyrus/rustnet
brew install rustnet
```

## Usage

RustNet requires elevated privileges to capture network packets. You have several options:

### macOS
```bash
# Option 1: Run with sudo (simplest)
sudo rustnet

# Option 2: Configure BPF permissions (recommended)
brew install --cask wireshark-chmodbpf
# Log out and back in, then run without sudo:
rustnet
```

### Linux
```bash
# Option 1: Run with sudo
sudo $(which rustnet)

# Option 2: Grant capabilities to the binary
# Resolve symlink first (setcap doesn't work on symlinks)
RUSTNET_BIN=$(realpath $(which rustnet))
sudo setcap 'cap_net_raw,cap_bpf,cap_perfmon=eip' "$RUSTNET_BIN"
rustnet
```

## GeoIP Databases (Optional)

RustNet supports GeoIP lookups to show country codes, city names, and ASN information for remote IPs. Install the GeoLite2 databases via `brew install geoipupdate` (requires a free MaxMind account), then set `EditionIDs` in `$(brew --prefix)/etc/GeoIP.conf`:

```
# City database includes country data — no need for GeoLite2-Country:
EditionIDs GeoLite2-City GeoLite2-ASN
```

Then run `geoipupdate` to download the databases. See the [GeoIP setup guide](https://github.com/domcyrus/rustnet/blob/main/INSTALL.md#geoip-databases-optional) for full instructions.

## Automatic Updates

This tap is automatically updated hourly via GitHub Actions. When a new RustNet release is published, the formula is updated with the latest version and SHA256 checksum.

## Links

- **Main Project**: https://github.com/domcyrus/rustnet
- **Documentation**: https://github.com/domcyrus/rustnet
  - **Permissions**: https://github.com/domcyrus/rustnet/blob/main/INSTALL.md#permissions-setup
- **Issues**: https://github.com/domcyrus/rustnet/issues

## License

Apache License 2.0 - see the [LICENSE](https://github.com/domcyrus/rustnet/blob/main/LICENSE) in the main RustNet repository.

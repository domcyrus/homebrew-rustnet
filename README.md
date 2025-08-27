# Homebrew RustNet

Homebrew tap for [RustNet](https://github.com/domcyrus/rustnet) - a high-performance, cross-platform network monitoring terminal UI tool built with Rust.

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
sudo rustnet

# Option 2: Grant capabilities to the binary
sudo setcap cap_net_raw,cap_net_admin=eip $(which rustnet)
rustnet
```

## Links

- **Main Project**: https://github.com/domcyrus/rustnet
- **Documentation**: https://github.com/domcyrus/rustnet#permissions
- **Issues**: https://github.com/domcyrus/rustnet/issues


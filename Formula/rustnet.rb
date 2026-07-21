class Rustnet < Formula
  desc "High-performance, cross-platform network monitoring tool with TUI"
  homepage "https://github.com/domcyrus/rustnet"
  license "Apache-2.0"
  uses_from_macos "libpcap"
  uses_from_macos "zlib"

  on_macos do
    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.5.0/rustnet-v1.5.0-aarch64-apple-darwin.tar.gz"
      sha256 "dcbff487d3edc8bdd490e1b1ff85b7b00273c05cbae5653d733d4f8c5461504b"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.5.0/rustnet-v1.5.0-x86_64-apple-darwin.tar.gz"
      sha256 "888bf5f52110eff439bed2435058d4af1f15d8c6ba31cd58a031b350a1613f17"
    end
  end

  on_linux do
    # Static musl binaries - no runtime dependencies needed
    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.5.0/rustnet-v1.5.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "6b7dbf5d19adafa1111ad35990d6da2c440f90929b8a448357a7a662b7b44548"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.5.0/rustnet-v1.5.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "cd75bee206e0a8d4b638f1c081975ab15aacb868acce2597c41ab104b193b808"
    end
  end

  def install
    bin.install "rustnet"
  end

  def caveats
    s = <<~EOS
      RustNet requires elevated privileges to capture network packets.

    EOS

    on_macos do
      s += <<~EOS
        On macOS, you have several options:

        1. Run with sudo (simplest):
           sudo rustnet

        2. Add yourself to the access_bpf group (recommended):
           - Install Wireshark's ChmodBPF helper:
             brew install --cask wireshark-chmodbpf
           - This will create the access_bpf group and configure BPF permissions
           - Log out and back in for changes to take effect
           - Then run rustnet without sudo

        3. Manual BPF configuration (alternative to option 2):
           sudo dseditgroup -o edit -a $USER -t user access_bpf
           Log out and back in for changes to take effect

        Note: Options 2 and 3 allow running without sudo, but will use lsof for
        process identification instead of PKTAP. Both work, but PKTAP (option 1)
        is faster and more accurate.

      EOS
    end

    on_linux do
      s += <<~EOS
        On Linux, you have two options:

        1. Run with sudo (simplest):
           sudo $(which rustnet)

        2. Grant minimal capabilities (recommended - no root required!):
           # Resolve symlink first (setcap doesn't work on symlinks)
           RUSTNET_BIN=$(realpath $(which rustnet))

           # Modern kernel (5.8+) with eBPF support:
           sudo setcap 'cap_net_raw,cap_bpf,cap_perfmon=eip' "$RUSTNET_BIN"

           # Legacy kernel (older than 5.8):
           sudo setcap 'cap_net_raw,cap_sys_admin=eip' "$RUSTNET_BIN"

           Then run rustnet without sudo

        Note: RustNet uses read-only packet capture (CAP_NET_ADMIN not required)

      EOS
    end

    s += <<~EOS
      GeoIP (optional):
        To show country codes and city names for remote IPs, install GeoLite2
        databases (requires a free MaxMind account at https://www.maxmind.com):
          brew install geoipupdate
        Edit #{HOMEBREW_PREFIX}/etc/GeoIP.conf and set EditionIDs, e.g.:
          EditionIDs GeoLite2-City GeoLite2-ASN
        Then run: geoipupdate
        Tip: GeoLite2-City includes country data — no need for GeoLite2-Country.
        See: https://github.com/domcyrus/rustnet/blob/main/INSTALL.md#geoip-databases-optional

      For more information, see: https://github.com/domcyrus/rustnet#permissions
    EOS

    s
  end

  test do
    assert_match "rustnet #{version}", shell_output("#{bin}/rustnet --version")
  end
end

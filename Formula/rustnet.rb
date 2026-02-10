class Rustnet < Formula
  desc "High-performance, cross-platform network monitoring tool with TUI"
  homepage "https://github.com/domcyrus/rustnet"
  license "Apache-2.0"
  uses_from_macos "libpcap"
  uses_from_macos "zlib"

  on_macos do
    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.0.0/rustnet-v1.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "d8e6ba0bc890c0f47d1f5f9359ec201e964a043c593c414d7f82288feae84bfe"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.0.0/rustnet-v1.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "db3287468888fc42bd91e3764fa4fcafeb6ae54dcee5be14a13f45829d495c52"
    end
  end

  on_linux do
    # Static musl binaries - no runtime dependencies needed
    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.0.0/rustnet-v1.0.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0019dfc4b32d63c1392aa264aed2253c1e0c2fb09216f8e2cc269bbfb8bb49b5"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v1.0.0/rustnet-v1.0.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "7f8042a6a8d9c2ea5919ac5d1b262ebc8ec36f1ea5b89068231a2ca754d9aaf7"
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
      For more information, see: https://github.com/domcyrus/rustnet#permissions
    EOS

    s
  end

  test do
    assert_match "rustnet #{version}", shell_output("#{bin}/rustnet --version")
  end
end

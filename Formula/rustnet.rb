class Rustnet < Formula
  desc "High-performance, cross-platform network monitoring tool with TUI"
  homepage "https://github.com/domcyrus/rustnet"
  license "Apache-2.0"

  uses_from_macos "libpcap"
  uses_from_macos "zlib"

  on_macos do
    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.17.0/rustnet-v0.17.0-aarch64-apple-darwin.tar.gz"
      sha256 "91008538d02d05cdf16175bdaddddb510f88bbe4684acc2cebac702ed310f82a"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.17.0/rustnet-v0.17.0-x86_64-apple-darwin.tar.gz"
      sha256 "d2d5b55ba4bfc6b451b91caf17b813b465ec07f2a8abe17c4fa49ef695895014"
    end
  end

  on_linux do
    depends_on "elfutils"
    depends_on "libpcap"

    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.17.0/rustnet-v0.17.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "7638dee6e2a7fd03e30a32e3ff1159a00c232b8955d42cd2027fef4c0c4dcdf1"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.17.0/rustnet-v0.17.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "79e0904424a984893227db289b81d8b32f6f2c89e864285011df9d03d8f00fd9"
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
           sudo rustnet

        2. Grant minimal capabilities (recommended - no root required!):
           # Modern kernel (5.8+) with eBPF support:
           sudo setcap 'cap_net_raw,cap_bpf,cap_perfmon=eip' $(which rustnet)

           # Legacy kernel (older than 5.8):
           sudo setcap 'cap_net_raw,cap_sys_admin=eip' $(which rustnet)

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

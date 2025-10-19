class Rustnet < Formula
  desc "High-performance, cross-platform network monitoring tool with TUI"
  homepage "https://github.com/domcyrus/rustnet"
  url "https://github.com/domcyrus/rustnet/archive/refs/tags/v0.14.0.tar.gz"
  sha256 "92c252523ab9c7ab6b2f844aab995d8ef11a6140039c003dd68a58ddd2ef3372"
  license "Apache-2.0"

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  uses_from_macos "libpcap"
  uses_from_macos "zlib"

  on_linux do
    depends_on "llvm" => :build
    depends_on "elfutils"
    depends_on "libpcap"
  end

  def install
    args = std_cargo_args
    args += ["--features", "linux-default"] if OS.linux?
    system "cargo", "install", *args
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

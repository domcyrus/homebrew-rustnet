class Rustnet < Formula
  desc "High-performance, cross-platform network monitoring tool with TUI"
  homepage "https://github.com/domcyrus/rustnet"
  url "https://github.com/domcyrus/rustnet/archive/refs/tags/v0.13.0.tar.gz"
  sha256 "fb1b429b8a9a68bfeab489aafa5d4e2c42e1525ac626331e8918e50c932e7be9"
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

        2. Grant capabilities to the binary (recommended):
           sudo setcap cap_net_raw,cap_net_admin=eip $(which rustnet)
           Then run rustnet without sudo

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

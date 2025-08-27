class Rustnet < Formula
  desc "High-performance, cross-platform network monitoring tool with TUI"
  homepage "https://github.com/domcyrus/rustnet"
  url "https://github.com/domcyrus/rustnet/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "22a9db0235c20ec4a977b9d6af240ad90729784f0d6f52915b8c5cc6258082e7"
  license "Apache-2.0"

  depends_on "rust" => :build
  depends_on "pkg-config" => :build

  uses_from_macos "libpcap"

  on_linux do
    depends_on "libpcap"
  end

  def install
    system "cargo", "install", *std_cargo_args
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

        3. Manual BPF configuration:
           sudo dseditgroup -o edit -a $USER -t user access_bpf

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
      For more information, see: https://github.com/yourusername/rustnet#permissions
    EOS

    s
  end

  test do
    assert_match "rustnet #{version}", shell_output("#{bin}/rustnet --version")
  end
end

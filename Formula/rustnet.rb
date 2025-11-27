class Rustnet < Formula
  desc "High-performance, cross-platform network monitoring tool with TUI"
  homepage "https://github.com/domcyrus/rustnet"
  license "Apache-2.0"

  uses_from_macos "libpcap"
  uses_from_macos "zlib"

  on_macos do
    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.16.1/rustnet-v0.16.1-aarch64-apple-darwin.tar.gz"
      sha256 "a09327d8e1415eb8bcfc4d31f41d32e87d648c6e5a369ee1accfc849bf50f1a4"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.16.1/rustnet-v0.16.1-x86_64-apple-darwin.tar.gz"
      sha256 "a1b66058c03aa08df5b0980fda86ef333cc41dd5acd49e8040acefe4a311465e"
    end
  end

  on_linux do
    depends_on "elfutils"
    depends_on "libpcap"

    on_arm do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.16.1/rustnet-v0.16.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c8a88f122fe5c3fb59e8f59d402d1768cdf08546959c99b223c9fcd70537cf2a"
    end
    on_intel do
      url "https://github.com/domcyrus/rustnet/releases/download/v0.16.1/rustnet-v0.16.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "d589d753200759232bfdfbc7dec9191ad86c6fafa0f3122c873daa05b2dc152f"
    end
  end

  def install
    bin.install Dir["*/rustnet"].first
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

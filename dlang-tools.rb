class DlangTools < Formula
  desc "D programming language tools"
  homepage "https://dlang.org/"
  url "https://github.com/dlang/tools/archive/master.tar.gz"


  depends_on "automake"
  depends_on "dmd"
  depends_on "dub"

  def install
    system "make" "-f" "posix.mak" "all" "INSTALL_DIR=#{prefix}"
    system "make" "-f" "posix.mak" "install" "INSTALL_DIR=#{prefix}"

    end

    test do
      system "rdmd"
      system "which" "rdmd"

    end
end


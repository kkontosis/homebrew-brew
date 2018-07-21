class DlangTools < Formula
  desc "D programming language tools"
  homepage "https://dlang.org/"
  head "https://github.com/dlang/tools.git"
  url "https://github.com/dlang/tools/archive/master.tar.gz"
  version "1.0"

  depends_on "automake"
  depends_on "dmd"
  depends_on "dub"

  def install
    system "make", "-f", "posix.mak", "all", "test_tests_extractor", "DMD=dmd", "INSTALL_DIR=#{prefix}"
    system "make", "-f", "posix.mak", "install", "DMD=dmd", "INSTALL_DIR=#{prefix}"

    end

    test do
      system "rdmd"
      system "which", "rdmd"

    end
end


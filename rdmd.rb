class Rdmd < Formula
  desc "D programming language tool rdmd"
  homepage "https://dlang.org/rdmd.html"
  head "https://github.com/dlang/tools.git"
  url "https://github.com/dlang/tools/archive/master.tar.gz"
  version "1.0"

  # The rdmd binary already exists in dmd Cellar but it is not linked.
  # An easier approach would be to link it
  # Here, experimenting with a full build

  depends_on "automake"
  depends_on "dmd"
  depends_on "dub"

  def install
    system "make", "-f", "posix.mak", "rdmd", "DMD=dmd", "INSTALL_DIR=#{prefix}"
    # system "make", "-f", "posix.mak", "install", "DMD=dmd", "INSTALL_DIR=#{prefix}"

    system "bash", "-c", "cp generated/*/*/rdmd ."
    system "cp", "./rdmd", "#{prefix}/bin"
  end

  test do
    system "which", "rdmd"

  end
end


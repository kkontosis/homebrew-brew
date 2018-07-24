class Rdmd < Formula
  desc "D programming language tool rdmd symlink"
  homepage "https://dlang.org/rdmd.html"
  head "https://github.com/dlang/tools.git"
  url "https://github.com/dlang/tools/archive/master.tar.gz"
  version "1.0"

  # The rdmd binary already exists in dmd Cellar but it is not linked in some cases.
  # Additionally installs dub

  depends_on "automake"
  depends_on "dmd"
  depends_on "dub"

  def install

    system "bash", "-c", "test -f /usr/local/bin/rdmd || ln -s /usr/local/Cellar/dmd/2.*/bin/rdmd /usr/local/bin/rdmd"

  end

  test do
    system "which", "rdmd"

  end
end


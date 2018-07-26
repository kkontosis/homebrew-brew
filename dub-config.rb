class DubConfig < Formula
  desc "D language helper build utility that extracts library include paths from the dub package manager configuration"
  homepage "https://github.com/kkontosis/dub-config"
  head "https://github.com/kkontosis/dub-config.git"
  url "https://github.com/kkontosis/dub-config/archive/master.tar.gz"
  version "1.0"

  depends_on "dmd"
  depends_on "dub"

  def install
    system "dub", "build"

    system "mkdir", "-p", "#{prefix}/bin"
    system "cp", "./dub-config", "#{prefix}/bin"
  end

  test do
    system "which", "dub-config"
  end
end


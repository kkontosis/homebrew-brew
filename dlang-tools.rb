class DlangTools < Formula
  desc "D programming language tools"
  homepage "https://dlang.org/"
  head "https://github.com/dlang/tools.git"

  depends_on "automake"
  depends_on "dmd"
  depends_on "dub"

  def install
    system "make" "-f" "posix.mak" "all"
    system "make" "-f" "posix.mak" "install"

    # inreplace "fluidsynth/Makefile", "lv2-plugin", "lv2"

    # ["fluidsynth", "pitchdetect", "shimmer", "amp_with_gui"].each do |plugin| # "visual_compressor" needs lv2-c++-tools
    #   cd "#{buildpath}/#{plugin}" do
    #     system "make", "install", "INSTALL_DIR=#{lib}/lv2"
    #   end
    end

    test do
      system "rdmd"
      system "which" "rdmd"

    end
end


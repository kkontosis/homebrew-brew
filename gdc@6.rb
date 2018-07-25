class GdcAT6 < Formula
  desc "GNU D compiler"
  homepage "https://gdcproject.org/"
  url "https://ftp.gnu.org/gnu/gcc/gcc-6.4.0/gcc-6.4.0.tar.xz"
  mirror "https://ftpmirror.gnu.org/gcc/gcc-6.4.0/gcc-6.4.0.tar.xz"
  # sha256 "850bf21eafdfe5cd5f6827148184c08c4a0852a37ccf36ce69855334d2c914d4"
  revision 2

  # bottle do
  #   sha256 "2d073860c3899b3d61441931ebb230ccb7249e2ac63d957860c408c01ecc081b" => :high_sierra
  #   sha256 "c9f0ebfe118e7c43a081e952dd0135e7b6621a9f935426fd08372486fa5ddea9" => :sierra
  #   sha256 "cfb7468673433e7ef683f1746fb94ce9719c181e9c7e86f4d70453578c1822cc" => :el_capitan
  # end

  option "with-all-languages", "Enable all compilers and languages, except Ada"
  option "with-nls", "Build with native language support (localization)"
  option "with-jit", "Build the jit compiler"
  option "without-fortran", "Build without the gfortran compiler"

  depends_on "coreutils"

  depends_on "gmp"
  depends_on "libmpc"
  depends_on "mpfr"
  depends_on "isl"

  fails_with :gcc_4_0

  # GCC bootstraps itself, so it is OK to have an incompatible C++ stdlib
  cxxstdlib_check :skip

  # The bottles are built on systems with the CLT installed, and do not work
  # out of the box on Xcode-only systems due to an incorrect sysroot.
  # pour_bottle? do
  #   reason "The bottle needs the Xcode CLT to be installed."
  #   satisfy { MacOS::CLT.installed? }
  # end

  # Fix for libgccjit.so linkage on Darwin
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=64089
  # https://github.com/Homebrew/homebrew-core/issues/1872#issuecomment-225625332
  # https://github.com/Homebrew/homebrew-core/issues/1872#issuecomment-225626490
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/e9e0ee09389a54cc4c8fe1c24ebca3cd765ed0ba/gcc/6.1.0-jit.patch"
    sha256 "863957f90a934ee8f89707980473769cff47ca0663c3906992da6afb242fb220"
  end

  # Fix parallel build on APFS filesystem
  # Remove for 6.5.0 and later
  # https://gcc.gnu.org/bugzilla/show_bug.cgi?id=81797
  if MacOS.version >= :high_sierra
    patch do
      url "https://raw.githubusercontent.com/Homebrew/formula-patches/df0465c02a/gcc/apfs.patch"
      sha256 "f7772a6ba73f44a6b378e4fe3548e0284f48ae2d02c701df1be93780c1607074"
    end
  end

  def install
    # Download gdc to a subdirectory named .gdc
    system "git", "clone", "https://github.com/D-Programming-GDC/GDC.git", ".gdc"
    system "wget", "https://raw.githubusercontent.com/kkontosis/homebrew-brew/master/gdc-6.0-osx-patch.patch"
    system "bash", "-c", "cd .gdc && patch -p1 <../gdc-6.0-osx-patch.patch ; cd .."

    # First we will patch gcc to become gdc (awesome!)
    system "bash", "-c", "cd .gdc && git checkout gdc-6 && ./setup-gcc.sh .. ; cd .."

    # GCC will suffer build errors if forced to use a particular linker.
    ENV.delete "LD"

    version_suffix = version.to_s.slice(/\d/)

    # Even when suffixes are appended, the info pages conflict when
    # install-info is run so pretend we have an outdated makeinfo
    # to prevent their build.
    ENV["gcc_cv_prog_makeinfo_modern"] = "no"

    osmajor = `uname -r`.chomp
    arch = MacOS.prefer_64_bit? ? "x86_64" : "i686"

    args = [
      "--build=#{arch}-apple-darwin#{osmajor}",
      "--prefix=#{prefix}",
      "--libdir=#{lib}/gdc/#{version_suffix}",
      "--enable-languages=d",
      # Make most executables versioned to avoid conflicts.
      "--program-suffix=-#{version_suffix}",
      "--disable-bootstrap",
      "--disable-multilib",
      "--disable-libgomp",
      "--disable-libmudflap",
      "--disable-libquadmath",
      "--with-gmp=#{Formula["gmp"].opt_prefix}",
      "--with-mpfr=#{Formula["mpfr"].opt_prefix}",
      "--with-mpc=#{Formula["libmpc"].opt_prefix}",
      "--with-isl=#{Formula["isl"].opt_prefix}",
      "--with-system-zlib",
      "--enable-stage1-checking",
      "--enable-checking=release",
      "--enable-lto",
      # Use 'bootstrap-debug' build configuration to force stripping of object
      # files prior to comparison during bootstrap (broken by Xcode 6.3).
      "--with-build-config=bootstrap-debug",
      "--disable-werror",
      "--with-pkgversion=Homebrew GCC #{pkg_version} #{build.used_options*" "}".strip,
      "--with-bugurl=https://github.com/Homebrew/homebrew-core/issues",
      "--disable-libphobos"
    ]

    # The pre-Mavericks toolchain requires the older DWARF-2 debugging data
    # format to avoid failure during the stage 3 comparison of object files.
    # See: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=45248
    args << "--with-dwarf2" if MacOS.version <= :mountain_lion

    args << "--disable-nls" if build.without? "nls"

    if MacOS.prefer_64_bit?
      args << "--enable-multilib"
    else
      args << "--disable-multilib"
    end

    args << "--enable-host-shared" if build.with?("jit") || build.with?("all-languages")

    # Ensure correct install names when linking against libgcc_s;
    # see discussion in https://github.com/Homebrew/homebrew/pull/34303
    inreplace "libgcc/config/t-slibgcc-darwin", "@shlib_slibdir@", "#{HOMEBREW_PREFIX}/lib/gdc/#{version_suffix}"

    mkdir "build" do
      unless MacOS::CLT.installed?
        # For Xcode-only systems, we need to tell the sysroot path.
        # "native-system-headers" will be appended
        args << "--with-native-system-header-dir=/usr/include"
        args << "--with-sysroot=#{MacOS.sdk_path}"
      end

      system "../configure", *args
      # system "make", "bootstrap"
      # make will fail with tm_d.h not found, then we create this with make
      system "cmd", "-c", "make -j8 || cd gcc && make tm_d.h && cd .. && make -j 8"
      system "make", "install"
    end

    # Handle conflicts between GCC formulae and avoid interfering
    # with system compilers.
    # Rename man7.
    Dir.glob(man7/"*.7") { |file| add_suffix file, version_suffix }
    # Even when we disable building info pages some are still installed.
    info.rmtree
  end

  def add_suffix(file, suffix)
    dir = File.dirname(file)
    ext = File.extname(file)
    base = File.basename(file, ext)
    File.rename file, "#{dir}/#{base}-#{suffix}#{ext}"
  end

  test do
    (testpath/"hello-c.c").write <<~EOS
      #include <stdio.h>
      int main()
      {
        puts("Hello, world!");
        return 0;
      }
    EOS
    system "#{bin}/gcc-6", "-o", "hello-c", "hello-c.c"
    assert_equal "Hello, world!\n", `./hello-c`

    (testpath/"hello-cc.cc").write <<~EOS
      #include <iostream>
      int main()
      {
        std::cout << "Hello, world!" << std::endl;
        return 0;
      }
    EOS
    system "#{bin}/g++-6", "-o", "hello-cc", "hello-cc.cc"
    assert_equal "Hello, world!\n", `./hello-cc`

    (testpath/"hello-d.d").write <<~EOS
      import std.stdio;
      int main()
      {
        writeln("Hello, world!");
        return 0;
      }
    EOS
    system "#{bin}/g++-6", "-o", "hello-d", "hello-d.d"
    assert_equal "Hello, world!\n", `./hello-d`

  end
end

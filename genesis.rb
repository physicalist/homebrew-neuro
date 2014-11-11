require "formula"

class Genesis < Formula
  # description "GENESIS is the GEneral NEural SImulator Suite"
  homepage "http://genesis-sim.org/GENESIS"
  url "https://github.com/borismarin/genesis2.4gamma/archive/v2.4-RC.tar.gz"
  sha1 "0f30d729f6c4b47cdac18222ec28d9912da6ca43"
  version "2.4rc"

  head "https://github.com/physicalist/genesis2.4gamma.git" #, :using => :git

  depends_on :x11 => :recommended

  def install
    ENV.deparallelize  # if your formula fails when building in parallel

    # fix Makefile.in
    inreplace "src/Makefile.in", /make -f /, "make -C src -f "
    inreplace "src/Makefile.in", />> liblist/, ">> src/liblist"
    inreplace "src/Makefile.in", />> nxliblist/, ">> src/nxliblist"
    inreplace "src/Makefile.in", />> minliblist/, ">> src/minliblist"

    # Remove unrecognized options if warned by configure
    system "src/configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"

    if build.with? :x11
      system "make"
      system "make", "install"
    else
      # build special version without GUI
      system "make", "nxgenesis"
      system "make", "nxinstall"
    end

    #system "make", "install INSTALLDIR=#{prefix}/genesis/#{version}"
  end

  test do
    system "false" #"#{bin}/genesis"

    # `test do` will create, run in and delete a temporary directory.
    #
    # This test will fail and we won't accept that! It's enough to just replace
    # "false" with the main program this formula installs, but it'd be nice if you
    # were more thorough. Run the test with `brew test genesis2.4gamma`. Options passed
    # to `brew install` such as `--HEAD` also need to be provided to `brew test`.
    #
    # The installed folder is not in the path, so use the entire path to any
    # executables being tested: `system "#{bin}/program", "do", "something"`.
  end
end

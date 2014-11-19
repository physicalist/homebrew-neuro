require 'formula'

# NEST is the NEural Simulation Tool

class Nest < Formula
  homepage 'http://www.nest-initiative.org'
  url 'http://www.nest-initiative.org/download/gplreleases/nest-2.2.2.tar.gz'
  sha1 '275a1d658fdbb5f9f4ffcadd878c341eac495169'

  option "without-python", "Do not build python bindings (saves some time but not recommended; pyNN wouldn't work, among other things)"
  option "without-gsl", "Don't use Gnu scientific library (GSL) for extended numerical possibilites (NOT recommended, WILL break some neuron models)"

  option "enable-pthread", "Use pthreads"
  option "enable-openmpi", "Use OpenMPI"

  fails_with :clang do
    build 600
    cause <<-EOS.undent
      Building with Clang in Xcode 6.0 fails in randomgen.cpp:30:3:
      Trying to access private constructor in STL's iterator
      > error: field of type 'std::vector<double>::const_iterator'
      > (aka '__wrap_iter<const_pointer>') has private constructor
      > next_(0),
      > ^
    EOS
  end

  fails_with :llvm do
    build 600
    cause <<-EOS.undent
      Fails in randomgen.cpp:30:3:
      Trying to access private constructor in STL's iterator
      > error: field of type 'std::vector<double>::const_iterator'
      > (aka '__wrap_iter<const_pointer>') has private constructor
      > next_(0),
      > ^
     EOS
  end

  depends_on :python => :recommended
  depends_on "gsl" => :recommended
  depends_on "open-mpi" if build.include? 'enable-openmpi'

  depends_on "homebrew/python/scipy" if build.include? "python"

  def install
    args = [ "--disable-debug",
             "--disable-dependency-tracking",
             "--prefix=#{prefix}" ]

    # Clang still doesn't have OpenMP support!
    args << '--without-openmp' if ENV.compiler == :clang

    # building with openmpi support will probably fail...
    args << 'with-openmpi' if build.include? 'enable-openmpi'
    args << 'with-pthread' if build.include? 'enable-pthread'

    system "./configure", *args
    system "make install"
  end

  test do
    # simple check whether NEST was compiled & linked
    system "#{bin}/nest", "--version"

    # use pyNEST's built-in test suite
    python do
      system python, "-c", "import nest; nest.test()"
    end
  end

  def caveats; <<-EOS.undent
    Clang does not support OpenMP!
    Building NEST with Clang enforces --without-openmp!"
    EOS
  end
end

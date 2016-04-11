require "language/go"

class Devd < Formula
  desc "Local webserver for developers"
  homepage "https://github.com/cortesi/devd"
  url "https://github.com/cortesi/devd/archive/v0.5.tar.gz"
  sha256 "328d134eb408e8fa9ae798b077c2ba26b722b0db422474ff6d762faee0b89d27"
  head "https://github.com/cortesi/devd.git"
  revision 1

  bottle do
    cellar :any_skip_relocation
    sha256 "ffbb35f50786b77dbc2faea536b46ae00163031c49ef5288531442651cd0572b" => :el_capitan
    sha256 "3aed659dffe2ce0bca251783ca0a1c262c51144d2164892f5b32d57ed6d79f06" => :yosemite
    sha256 "7a6b20daaba595a801a4ec0b512db3887569e5da47e0d4ce6d663db1c069c1d3" => :mavericks
  end

  depends_on "go" => :build

  go_resource "github.com/mitchellh/go-homedir" do
    url "https://github.com/mitchellh/go-homedir.git",
        :revision => "981ab348d865cf048eb7d17e78ac7192632d8415"
  end

  go_resource "github.com/toqueteos/webbrowser" do
    # v1.0
    url "https://github.com/toqueteos/webbrowser.git",
        :revision => "21fc9f95c83442fd164094666f7cb4f9fdd56cd6"
  end

  go_resource "github.com/alecthomas/template" do
    url "https://github.com/alecthomas/template.git",
        :revision => "14fd436dd20c3cc65242a9f396b61bfc8a3926fc"
  end

  go_resource "github.com/alecthomas/units" do
    url "https://github.com/alecthomas/units.git",
        :revision => "2efee857e7cfd4f3d0138cc3cbb1b4966962b93a"
  end

  go_resource "gopkg.in/alecthomas/kingpin.v2" do
    # v2.1.11
    url "https://github.com/alecthomas/kingpin.git",
        :revision => "8cccfa8eb2e3183254457fb1749b2667fbc364c7"
  end

  go_resource "github.com/cortesi/modd" do
    # v0.3
    url "https://github.com/cortesi/modd.git",
        :revision => "9383745c78c806f4d61096a1ff401433c30a4e14"
  end

  go_resource "github.com/cortesi/termlog" do
    url "https://github.com/cortesi/termlog.git",
        :revision => "c1c2c2cb2b7f6e7ac97795a2947ffaf70cd93d47"
  end

  def install
    ENV["GOOS"] = "darwin"
    ENV["GOARCH"] = MacOS.prefer_64_bit? ? "amd64" : "386"
    ENV["GOPATH"] = buildpath

    # build vendored go.rice:
    ln_sf buildpath/"vendor", buildpath/"src"
    system "go", "install", "github.com/GeertJohan/go.rice/rice"
    rm_f buildpath/"src"

    ENV.prepend_path "PATH", buildpath/"bin"

    # build devd:
    mkdir_p buildpath/"src/github.com/cortesi/"
    ln_sf buildpath, buildpath/"src/github.com/cortesi/devd"
    Language::Go.stage_deps resources, buildpath/"src"

    system "rice", "embed-go"
    system "go", "build", "-o", "#{bin}/devd", "./cmd/devd"
    doc.install "README.md"
  end

  test do
    begin
      io = IO.popen("#{bin}/devd #{testpath}")
      sleep 2
    ensure
      Process.kill("SIGINT", io.pid)
      Process.wait(io.pid)
    end

    assert_match "Listening on http://devd.io", io.read
  end
end

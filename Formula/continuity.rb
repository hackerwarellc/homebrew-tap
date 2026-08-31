# typed: false
# frozen_string_literal: true

# Continuity — synthetic memory for AI coding assistants.
# Installs @continuity/cli + @continuity/mcp from npm (proprietary).
#
#   brew tap hackerwarellc/tap
#   brew install continuity
#
# Bump versions: node scripts/update-homebrew-formula.js (repo root)
class Continuity < Formula
  CLI_VERSION = "3.9.2"
  MCP_VERSION = "3.0.122"

  desc "Synthetic memory CLI and MCP server for AI coding assistants"
  homepage "https://getcontinuity.io"
  url "https://registry.npmjs.org/@continuity/cli/-/cli-#{CLI_VERSION}.tgz"
  version CLI_VERSION
  sha256 "323fb4b12b72fd75aaee2d0d658ea274b5e964c3f16029ed41cb035166d13666"
  license "LicenseRef-Hackerware-Proprietary"

  depends_on "node"

  resource "continuity-mcp" do
    url "https://registry.npmjs.org/@continuity/mcp/-/mcp-#{MCP_VERSION}.tgz"
    sha256 "e4ae6744b957c91f60f43b5df6804b87436bd6846872dbc3725acfd3ba2ed258"
  end

  def install
    cli_libexec = libexec/"cli"
    mcp_libexec = libexec/"mcp"

    system "npm", "install", *std_npm_args(prefix: cli_libexec)

    resource("continuity-mcp").stage do
      system "npm", "install", *std_npm_args(prefix: mcp_libexec)
    end

    bin.install_symlink cli_libexec/"bin/continuity"
    bin.install_symlink mcp_libexec/"bin/continuity-mcp"
    bin.install_symlink mcp_libexec/"bin/continuity-setup" if (mcp_libexec/"bin/continuity-setup").exist?
  end

  test do
    assert_match CLI_VERSION, shell_output("#{bin}/continuity --version")
    assert_predicate bin/"continuity-mcp", :exist?
  end
end

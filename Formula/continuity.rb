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
  CLI_VERSION = "3.8.0"
  MCP_VERSION = "3.0.121"

  desc "Synthetic memory CLI and MCP server for AI coding assistants"
  homepage "https://getcontinuity.io"
  url "https://registry.npmjs.org/@continuity/cli/-/cli-#{CLI_VERSION}.tgz"
  version CLI_VERSION
  sha256 "7509119a9f769e8373a18a3ba93e886aa599849e1d64864852f863b355fcf2e0"
  license "LicenseRef-Hackerware-Proprietary"

  depends_on "node"

  resource "continuity-mcp" do
    url "https://registry.npmjs.org/@continuity/mcp/-/mcp-#{MCP_VERSION}.tgz"
    sha256 "df53fb8808f4bc71153ed6d1ff048499ed85e8f53eeadeee81e7aa76ec77c689"
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

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
  CLI_VERSION = "3.6.0"
  MCP_VERSION = "3.0.120"

  desc "Synthetic memory CLI and MCP server for AI coding assistants"
  homepage "https://getcontinuity.io"
  url "https://registry.npmjs.org/@continuity/cli/-/cli-#{CLI_VERSION}.tgz"
  version CLI_VERSION
  sha256 "7749857bd5c66842eb89dd3f63a40b92b7c416e33b74ad59ab8ed44e33dfa60f"
  license "LicenseRef-Hackerware-Proprietary"

  depends_on "node"

  resource "continuity-mcp" do
    url "https://registry.npmjs.org/@continuity/mcp/-/mcp-#{MCP_VERSION}.tgz"
    sha256 "1547bc67ac6cdb92b273fa67c8d221f6bb921340258552b6d8bf69b5cd77fc1d"
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

# frozen_string_literal: true

class TermuxDotfiles < Formula
  desc "Dotfiles for Termux AI Workspace (Zsh, Tmux, Neovim, AI tools)"
  homepage "https://github.com/ipproyectosysoluciones/termux-dotfiles"
  url "https://github.com/ipproyectosysoluciones/termux-dotfiles/archive/refs/tags/vVERSION_PLACEHOLDER.tar.gz"
  version "VERSION_PLACEHOLDER"
  sha256 "SHA256_PLACEHOLDER"
  license "MIT"
  keg_only :formula

  depends_on "bash" => :run
  depends_on "zsh" => :run
  depends_on "git" => :run

  def install
    # prefix.install MOVES files (FileUtils.mv), so the source file is gone
    # after the move. Install the script from prefix/ where it now lives.
    prefix.install Dir["*"]
    bin.install prefix/"scripts/termux-dotfiles-setup"
  end

  def post_install
    puts "\n==> IMPORTANT: Run the setup script to create dotfile symlinks"
    puts "    $ termux-dotfiles-setup"
    puts "\n==> Then reload your shell:"
    puts "    $ exec zsh"
  end

  test do
    assert_match "termux-dotfiles-setup", bin.to_s
  end
end
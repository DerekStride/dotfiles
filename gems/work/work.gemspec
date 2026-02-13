# frozen_string_literal: true

require_relative "lib/work/version"

Gem::Specification.new do |spec|
  spec.name = "work"
  spec.version = Work::VERSION
  spec.authors = ["derekstride"]
  spec.email = ["derek@stride.host"]

  spec.summary = "Unified workspace tool for tmux + git worktrees."
  spec.description = "Unified workspace tool for tmux + git worktrees."
  spec.homepage = "https://github.com/derekstride/dotfiles"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "logger"
end

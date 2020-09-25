railties_versions = [
  %w[3.2 3.2.22.5],
  %w[4.0 4.0.13],
  %w[4.1 4.1.16],
  %w[4.2 4.2.10],
  %w[5.0 5.0.7],
  %w[5.1 5.1.6],
  %w[5.2 5.2.0],
  %w[6.0 6.0.2],
]

railties_versions.each do |(version, railties)|
  gem_version = Gem::Version.new(version)

  appraise "railties#{version}" do
    gem "railties", "~> #{railties}"
    gem "capybara", "~> 2.18.0"

    if gem_version <= Gem::Version.new("4.0")
      gem "test-unit", "~> 3.0"
      gem "sqlite3" , "~> 1.3.13", platforms: :ruby
    elsif gem_version >= Gem::Version.new("6.0")
      gem "sqlite3" , "~> 1.4.2", platforms: :ruby
    else
      gem "sqlite3" , "~> 1.3.13", platforms: :ruby
    end
  end
end

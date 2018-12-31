require 'git'

describe Pheme do
  it 'has a version number' do
    expect(Pheme::VERSION).not_to be nil
  end

  it 'has version been bumped' do
    git = Git.open('.', log: Logger.new(nil))

    skip if git.current_branch == 'master'

    master_version_file = git.show('origin/master', 'lib/pheme/version.rb')
    master_version = master_version_file.match(/VERSION = ['"](.*)['"]/)[1]

    expect(Gem::Version.new(Pheme::VERSION)).to be > Gem::Version.new(master_version)
  end
end

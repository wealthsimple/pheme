require 'git'

describe Pheme do
  def get_version(git, branch = 'HEAD')
    git.grep('VERSION = ', 'lib/*/version.rb', { object: branch })
        .map { |_sha, matches| matches.first[1] }
        .map(&method(:parse_version))
        .reject(&:nil?)
        .first
  end

  def parse_version(string)
    string.match(/VERSION = ['"](.*)['"]/)[1]
  end

  it 'has a version number' do
    git = Git.open('.')
    head_version = get_version(git, 'HEAD')
    expect(head_version).not_to be_nil
  end

  it 'has a bumped version' do
    git = Git.open('.')
    skip('already on master branch, no need to compare versions') if git.current_branch == 'master'

    head_version = get_version(git, 'HEAD')
    master_version = get_version(git, 'origin/master')

    raise 'no version.rb file found on the current branch' if head_version.nil?
    raise 'no version.rb file found on the master branch' if master_version.nil?

    expect(Gem::Version.new(head_version)).to be > Gem::Version.new(master_version)
  end
end

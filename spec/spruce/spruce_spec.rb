require 'spec_helper'
require 'docker'
require 'serverspec'

describe "spruce image" do
  before(:all) {
    @image = Docker::Image.all().detect{|i| i.info['RepoTags'].include? 'spruce:latest' }
    set :docker_image, @image.id
  }

  it "should be available" do
    expect(@image).to_not be_nil
  end

  it "installs the right version of Alpine Linux" do
    expect(os_version).to include("Alpine Linux 3.3")
  end

  def os_version
    command("cat /etc/issue | head -1").stdout
  end

  it "checks if spruce binary exists and is a file" do
    expect(file(SPRUCE_BIN)).to be_file
  end

  it "checks if spruce binary is executable" do
    expect(file(SPRUCE_BIN)).to be_mode 755
  end

  it "has the spruce version #{SPRUCE_VERSION}" do
    expect(spruce_version).to eq("spruce - Version #{SPRUCE_VERSION} (master)")
  end

  def spruce_version
    command("spruce --version").stderr.strip
  end
end

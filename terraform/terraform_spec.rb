require 'spec_helper'
require 'docker'
require 'serverspec'

REQUIRED_BINARIES = %w{
  terraform
  terraform-provider-aws
  terraform-provider-null
  terraform-provider-template
  terraform-provider-tls
  terraform-provider-postgresql
  terraform-provisioner-file
  terraform-provisioner-local-exec
  terraform-provisioner-remote-exec
}

describe "Terraform image" do
  before(:all) {
    set :docker_image, find_image_id('terraform:latest')
  }

  it "installs Alpine" do
    expect(command("cat /etc/issue | head -1").stdout).to include("Alpine Linux")
  end

  it "installs Root Certificates" do
    expect(file("/usr/share/ca-certificates/mozilla/GlobalSign_Root_CA.crt")).to be_file
  end

  REQUIRED_BINARIES.each { |binary|
    it "required binary '#{binary}' is in path and executable" do
      command_path = command("which #{binary}").stdout.strip
      expect(command_path).not_to be_empty
      expect(file(command_path)).to be_mode 755
    end
  }

  it "has the expected Terraform version" do
    expect(
      command("terraform version").stdout
    ).to include("Terraform v0.6.15-dev")
  end

  it "installs SSH" do
    expect(
      command("ssh -V").stderr.strip
    ).to include("OpenSSH")
  end

  it "should not have binary directory larger than 200M" do
    expect(
      Integer(command("du -m /usr/local/bin").stdout.split.first)
    ).to be < 200
  end
end

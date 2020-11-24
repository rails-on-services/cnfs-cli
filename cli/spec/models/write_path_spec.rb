# frozen_string_literal: true

require 'spec_helper'

RSpec.describe WritePath, type: :model do
  subject { project.pather }
  let(:project) { Cnfs.project }
  let(:cwd) { Cnfs.cwd }
  let(:namespace_name) { project.namespace.name }
  let(:environment_name) { project.environment.name }

  it 'returns the correct relative path for manifests' do
    expect(subject.write_path.to_s).to eq("tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  it 'returns the correct absolute path for manifests' do
    expect(subject.write_path(:manifests, true).to_s).to eq("#{cwd}/tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  it 'returns the correct relative path for runtime' do
    expect(subject.write_path(:runtime).to_s).to eq("tmp/runtime/#{environment_name}/#{namespace_name}")
  end
end

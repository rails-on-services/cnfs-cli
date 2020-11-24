# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectPath, type: :model do
  subject { project.project_path }
  let(:project) { Cnfs.project }
  let(:cwd) { Cnfs.cwd }
  let(:namespace_name) { project.namespace.name }
  let(:environment_name) { project.environment.name }

  it 'returns the correct relative path for manifests' do
    expect(subject.path_to(:manifests).to_s).to eq("tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  it 'returns the correct absolute path for manifests' do
    expect(subject.absolute_path_to(:manifests).to_s).to eq("#{cwd}/tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  it 'returns the correct relative path for runtime' do
    expect(subject.path_to(:runtime).to_s).to eq("tmp/runtime/#{environment_name}/#{namespace_name}")
  end

  it 'returns the correct relative path from manifests to project_root' do
    expect(subject.relative_path(from: :manifests).to_s).to eq('../../../..')
  end

  it 'returns the correct relative path from manifests to repository' do
    expect(subject.relative_path(from: :manifests, to: :repository).to_s).to eq('../../../../src/ros')
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ProjectPath, type: :model do
  subject { project.project_path }
  let(:project) { Cnfs.project }
  let(:cwd) { Cnfs.cwd }
  let(:namespace_name) { project.namespace.name }
  let(:environment_name) { project.environment.name }

  it 'returns the correct relative path to manifests' do
    expect(subject.path(to: :manifests).to_s).to eq("tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  it 'returns the correct absolute path to manifests' do
    expect(subject.path(to: :manifests, absolute: true).to_s).to eq("#{cwd}/tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  it 'returns the correct relative path to the current repository' do
    expect(subject.path(to: :repository).to_s).to eq('src/ros')
  end

  it 'returns the correct relative path from manifests' do
    expect(subject.path(from: :manifests).to_s).to eq('../../../..')
  end

  it 'returns the correct relative path from manifests to the current repository' do
    expect(subject.path(from: :manifests, to: :repository).to_s).to eq('../../../../src/ros')
  end
end

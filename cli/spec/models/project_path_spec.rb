# frozen_string_literal: true

require 'spec_helper'

# rubocop:disable Metrics/BlockLength
RSpec.describe ProjectPath, type: :model do
  subject { project.project_path }
  let(:project) { Cnfs.project }
  let(:cwd) { Cnfs.context.cwd }
  let(:namespace_name) { project.namespace.name }
  let(:environment_name) { project.environment.name }

  xit 'returns the correct relative path to manifests' do
    expect(subject.path(to: :manifests).to_s).to eq("tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  xit 'returns the correct absolute path to manifests' do
    expect(subject.path(to: :manifests,
                        absolute: true).to_s).to eq("#{cwd}/tmp/manifests/#{environment_name}/#{namespace_name}")
  end

  xit 'returns the correct relative path to the current repository' do
    expect(subject.path(to: :repository).to_s).to eq('src/ros')
  end

  xit 'returns the correct relative path from manifests' do
    expect(subject.path(from: :manifests).to_s).to eq('../../../..')
  end

  xit 'returns the correct relative path from manifests to the current repository' do
    expect(subject.path(from: :manifests, to: :repository).to_s).to eq('../../../../src/ros')
  end

  xit 'returns the correct relative path from an absolute custom dir' do
    expect(subject.path(from: cwd.join('four/part/custom/dir').to_s).to_s).to eq('../../../..')
  end

  xit 'returns the correct relative path from an absolute custom dir to the current repository' do
    expect(subject.path(from: cwd.join('four/part/custom/dir').to_s, to: :repository).to_s).to eq('../../../../src/ros')
  end

  xit 'returns the correct relative path from a relative custom dir to the current repository' do
    expect(subject.path(from: 'four/part/custom/dir', to: :repository).to_s).to eq('../../../../src/ros')
  end
end
# rubocop:enable Metrics/BlockLength

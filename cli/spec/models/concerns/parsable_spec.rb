# frozen_string_literal: true

require 'spec_helper'

shared_examples_for 'parsable' do
# RSpec.describe Parsable, type: :model do
  # subject { project.project_path }
  # let(:project) { Cnfs.project }
  # let(:cwd) { Cnfs.cwd }
  let(:model) { described_class }
  # let(:environment_name) { project.environment.name }

  # it 'returns the correct relative path to manifests' do
  #   expect(subject.path(to: :manifests).to_s).to eq("tmp/manifests/#{environment_name}/#{namespace_name}")
  # end

  # it 'returns the correct absolute path to manifests' do
  #   expect(subject.path(to: :manifests, absolute: true).to_s).to eq("#{cwd}/tmp/manifests/#{environment_name}/#{namespace_name}")
  # end

  # it 'returns the correct relative path to the current repository' do
  #   expect(subject.path(to: :repository).to_s).to eq('src/ros')
  # end

  # it 'returns the correct relative path from manifests' do
  #   expect(subject.path(from: :manifests).to_s).to eq('../../../..')
  # end

  # it 'returns the correct relative path from manifests to the current repository' do
  #   expect(subject.path(from: :manifests, to: :repository).to_s).to eq('../../../../src/ros')
  # end

  # it 'returns the correct relative path from an absolute custom dir' do
  #   expect(subject.path(from: cwd.join('four/part/custom/dir').to_s).to_s).to eq('../../../..')
  # end

  # it 'returns the correct relative path from an absolute custom dir to the current repository' do
  #   expect(subject.path(from: cwd.join('four/part/custom/dir').to_s, to: :repository).to_s).to eq('../../../../src/ros')
  # end

  # it 'returns the correct relative path from a relative custom dir to the current repository' do
  #   expect(subject.path(from: 'four/part/custom/dir', to: :repository).to_s).to eq('../../../../src/ros')
  # end
end

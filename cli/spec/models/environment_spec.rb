# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Environment, type: :model do
  subject { Environment }
  let(:project) { Cnfs.project }
  # let(:user_file) { Cnfs.user_root.join(Cnfs.config.name, 'config/users.yml') }
  # let(:project_file) { Cnfs.project_root.join('config/users.yml') }
  # let(:user_joe_1) { { joe: { role: 'admin' } }.deep_stringify_keys }
  # let(:user_joe_2) { { joe: { role: 'user' } }.deep_stringify_keys }
  # let(:user_dave_2) { { dave: { role: 'admin' } }.deep_stringify_keys }

  before(:each) do
    puts 'before each'
    FileUtils.rm_f(user_file)
    FileUtils.rm_f(project_file)
  end

  it 'returns the correct count and value of Users', :aggregate_failures do
    File.open(project_file, 'w') { |f| f.write(user_joe_1.to_yaml) }
    Cnfs::Configuration.reload
    expect(subject.count).to eq(1)
    expect(subject.first.role).to eq('admin')
  end

  it 'returns the correct count and value of Users', :aggregate_failures do
    File.open(project_file, 'w') { |f| f.write(user_joe_1.to_yaml) }
    File.open(user_file, 'w') { |f| f.write(user_joe_2.merge(user_dave_2).to_yaml) }
    Cnfs::Configuration.reload
    expect(subject.count).to eq(2)
    expect(subject.find_by(name: :joe).role).to eq('user')
  end
end


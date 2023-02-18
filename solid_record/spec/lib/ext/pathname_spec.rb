# frozen_string_literal: true

class Stack; end
module OneStack; class Stack; end; end

RSpec.describe Pathname do
  subject(:pathname) { described_class }

  describe '#singular?' do
    context 'when test.yml' do
      it { expect(pathname.new('test.yml').singular?).to be_truthy }
    end

    context 'when tests.yml' do
      it { expect(pathname.new('tests.yml').singular?).to be_falsey }
    end
  end

  describe '#plural?' do
    context 'when tests.yml' do
      it { expect(pathname.new('tests.yml').plural?).to be_truthy }
    end

    context 'when test.yml' do
      it { expect(pathname.new('test.yml').plural?).to be_falsey }
    end
  end

  describe '#extension' do
    context "when users.yml" do
      it { expect(pathname.new('users.yml').extension).to eq('yml') }
    end

    context "when users" do
      it { expect(pathname.new('users').extension).to eq('') }
    end

    context "when ." do
      it { expect(pathname.new('.').extension).to eq('') }
    end
  end

  describe '#name' do
    context "when users.yml" do
      it { expect(pathname.new('users.yml').name).to eq('users') }
    end

    context "when users.yml." do
      it { expect(pathname.new('users.yml.').name).to eq('users.yml') }
    end

    context "when users" do
      it { expect(pathname.new('users').name).to eq('users') }
    end

    context "when users." do
      it { expect(pathname.new('users.').name).to eq('users') }
    end

    context "when ." do
      it { expect(pathname.new('.').name).to eq('') }
    end
  end
end

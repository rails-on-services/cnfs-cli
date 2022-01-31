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


  describe '#classify' do
    context 'when stacks' do
      subject(:pathname) { described_class.new('stacks') }

      context 'when namespace is nil' do
        it { expect(pathname.classify).to eq('Stack') }
      end

      context 'when namespace is :one_stack' do
        it { expect(pathname.classify('one_stack')).to eq('OneStack::Stack') }
      end
    end

    context 'when .' do
      subject(:pathname) { described_class.new('.') }

      context 'when namespace is nil' do
        it { expect(pathname.classify).to be_nil }
      end

      context 'when namespace is :one_stack' do
        it { expect(pathname.classify(:one_stack)).to be_nil }
      end
    end
  end

  describe '#safe_constantize' do
    context 'when stacks' do
      subject(:pathname) { described_class.new('stacks') }
      context 'when namespace is nil' do
        it { expect(pathname.safe_constantize).to eq(Stack) }
      end

      context 'when namespace is :one_stack' do
        it { expect(pathname.safe_constantize(:one_stack)).to eq(OneStack::Stack) }
      end

      context 'when namespace is :invalid' do
        it { expect(pathname.safe_constantize(:invalid)).to be_nil }
      end
    end

    context 'with pathname .' do
      subject(:pathname) { described_class.new('.') }
      it { expect(pathname.safe_constantize).to be_nil }
    end
  end

  describe '#last_element_match' do
    context "with path_map 'stacks/environments/targets'" do
      let(:path_map) { 'stacks/environments/targets' }

      context "when 'backend'" do
        it { expect(pathname.new('backend').last_element_match(path_map)).to eq('stacks') }
      end

      context "when 'backend/production'" do
        it { expect(pathname.new('backend/production').last_element_match(path_map)).to eq('environments') }
      end

      context "when 'backend/production/cluster'" do
        it { expect(pathname.new('backend/production/cluster').last_element_match(path_map)).to eq('targets') }
      end

      context "when 'backend/production/cluster/default'" do
        it { expect(pathname.new('backend/production/cluster/default').last_element_match(path_map)).to be_nil }
      end
    end
  end
end

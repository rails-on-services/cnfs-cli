# frozen_string_literal: true
#
require_relative '../../../lib/ext/string.rb'
# require 'pry'

RSpec.describe 'string' do
  describe 'cnfs_sub' do
    let(:tld) { { 'tld' => 'context.com' } }
    let(:domain) { { 'domain' => 'backend.${tld}' } }
    # let(:hosts) { { 'hosts' => ['one${domain}', 'two${domain}' ] } }

    it 'returns self if no references are provided' do
      string = 'backend.${tld}'
      expect(string.cnfs_sub).to eq(string)
    end

    it 'returns self if no interpolations are provided' do
      string = 'backend'
      expect(string.cnfs_sub(tld)).to eq(string)
    end

    it 'returns self if reference is an Integer' do
      string = 'backend.${tld}'
      expect(string.cnfs_sub(1)).to eq(string)
    end

    it 'returns self if reference is a Boolean' do
      string = 'backend.${tld}'
      expect(string.cnfs_sub(true)).to eq(string)
    end

    it 'interpolates backend.${tld}' do
     string = 'backend.${tld}'
      expect(string.cnfs_sub(tld)).to eq('backend.context.com')
    end

    it 'gracefully fails to interpolate backend.${domain}' do
      string = 'host.${domain}'
      expect(string.cnfs_sub(tld)).to eq(string)
    end

    it 'interpolates backend.${domain}' do
      string = 'host.${domain}'
      expect(string.cnfs_sub(tld, domain)).to eq('host.backend.${tld}')
    end
  end
end

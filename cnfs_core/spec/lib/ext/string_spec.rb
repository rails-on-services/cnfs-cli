# frozen_string_literal: true

require_relative '../../../lib/ext/string.rb'

RSpec.describe 'string' do
  describe 'cnfs_sub' do
    let(:tld) { { 'tld' => 'context.com' } }
    let(:domain) { { 'domain' => 'backend.${parent.tld}' } }
    let(:invalid) { { 'invalid' => { 'integer' => 1 } } }

    it 'returns self if no references are provided' do
      string = 'backend.${tld}'
      expect(string.cnfs_sub).to eq(string)
    end

    it 'returns self if no interpolations are provided' do
      string = 'backend'
      expect(string.cnfs_sub(parent: tld)).to eq(string)
    end

    it 'raises an ArgumentError if reference is an Integer' do
      expect { 'error${tld}'.cnfs_sub(1) }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if reference is a Boolean' do
      expect { 'error${tld}'.cnfs_sub(true) }.to raise_error(ArgumentError)
    end

    it 'raises an ArgumentError if reference is an Array ' do
      expect { 'error${tld}'.cnfs_sub(default: []) }.to raise_error(ArgumentError)
    end

    it 'interpolates backend.${tld}' do
      string = 'backend.${parent.tld}'
      expect(string.cnfs_sub(parent: tld)).to eq('backend.context.com')
    end

    it 'returns self when provided an non existing interpolation' do
      string = 'host.${parent.domain.invalid}'
      expect(string.cnfs_sub(parent: tld)).to eq(string)
    end

    it 'returns self when provided an non existing interpolation' do
      string = 'host.${parent.invalid.domain}'
      expect(string.cnfs_sub(parent: tld)).to eq(string)
    end

    it 'returns self when provided an empty interpolation' do
      string = 'host.${}'
      expect(string.cnfs_sub(parent: {})).to eq('host.${}')
    end

    it 'returns self when the found reference returns an Integer' do
      string = 'host.${parent.invalid.integer}'
      expect(string.cnfs_sub(parent: invalid)).to eq('host.${parent.invalid.integer}')
    end

    it 'returns the correct interpolation and invlald delimited interpolation when provided both' do
      string = 'host.${parent.tld}.${parent.invalid}'
      expect(string.cnfs_sub(parent: tld)).to eq('host.context.com.${parent.invalid}')
    end

    it 'recursively interpolates strings that require multiple interpolation' do
      string = 'host.${child.domain}'
      expect(string.cnfs_sub(parent: tld, child: domain)).to eq('host.backend.context.com')
    end

    it 'recursively interpolates strings that require multiple interpolation' do
      string = 'host.${domain}.this.${domain}'
      expect(string.cnfs_sub(parent: tld, default: domain)).to eq('host.backend.context.com.this.backend.context.com')
    end
  end
end

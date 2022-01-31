# frozen_string_literal: true

RSpec.describe String do
  describe '#interpolate' do
    let(:tld) { { 'tld' => 'context.com' } }
    let(:domain) { { 'domain' => 'backend.${parent.tld}' } }
    let(:invalid) { { 'invalid' => { 'integer' => 1 } } }

    context 'when invalid reference' do
      context 'with an Integer' do
        it { expect { 'error${tld}'.interpolate(1) }.to raise_error(ArgumentError) }
      end

      context 'with a Boolean' do
        it { expect { 'error${tld}'.interpolate(true) }.to raise_error(ArgumentError) }
      end

      context 'with an Array' do
        it { expect { 'error${tld}'.interpolate(default: []) }.to raise_error(ArgumentError) }
      end

      context "with no reference, 'backend.${tld}'" do
        let(:string) { 'backend.${tld}' }

        it { expect(string.interpolate).to eq(string) }
      end
    end

    context "with no interpolation string, 'backend'" do
      let(:string) { 'backend' }

      it { expect(string.interpolate(parent: tld)).to eq(string) }
    end

    context 'when valid reference' do
      context "with 'backend.${tld}'" do
        let(:string) { 'backend.${parent.tld}' }

        it { expect(string.interpolate(parent: tld)).to eq('backend.context.com') }
      end

      context "with invalid interpolation 'host.${parent.domain.invalid}'" do
        let(:string) { 'host.${parent.domain.invalid}' }

        it { expect(string.interpolate(parent: tld)).to eq(string) }
      end

      context "with invalid second element 'host.${parent.invalid.domain}'" do
        let(:string) { 'host.${parent.invalid.domain}' }

        it { expect(string.interpolate(parent: tld)).to eq(string) }
      end

      context "with an empty interpolation 'host.${}'" do
        let(:string) { 'host.${}' }

        it { expect(string.interpolate(parent: {})).to eq('host.${}') }
      end

      context 'with the found reference returns an Integer' do
        let(:string) { 'host.${parent.invalid.integer}' }

        it { expect(string.interpolate(parent: invalid)).to eq('host.${parent.invalid.integer}') }
      end

      context "with one valid and one invalid interpolation 'host.${parent.tld}.${parent.invalid}'" do
        let(:string) { 'host.${parent.tld}.${parent.invalid}' }

        it { expect(string.interpolate(parent: tld)).to eq('host.context.com.${parent.invalid}') }
      end

      context 'with multiple interpolations required' do
        context "when string is 'host.${child.domain}'" do
          let(:string) { 'host.${child.domain}' }

          it { expect(string.interpolate(parent: tld, child: domain)).to eq('host.backend.context.com') }
        end

        context "with recursive interpolatitons 'host.${domain}.this.${domain}'" do
          let(:string) { 'host.${domain}.this.${domain}' }

          it {
            expect(string.interpolate(parent: tld,
                                      default: domain)).to eq('host.backend.context.com.this.backend.context.com')
          }
        end
      end
    end
  end
end

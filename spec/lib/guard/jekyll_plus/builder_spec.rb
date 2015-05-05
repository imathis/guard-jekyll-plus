require 'guard/compat/test/helper'

require 'guard/jekyll_plus/builder'

module Guard
  RSpec.describe JekyllPlus::Builder do
    let(:config) { instance_double(JekyllPlus::Config) }
    let(:site) { instance_double(Jekyll::Site) }
    let(:rebuilder) { instance_double(JekyllPlus::Builder::Rebuilder) }
    let(:modifier) { instance_double(JekyllPlus::Builder::Modifier) }
    let(:adder) { instance_double(JekyllPlus::Builder::Adder) }
    let(:remover) { instance_double(JekyllPlus::Builder::Remover) }

    subject { described_class.new(config) }

    before do
      allow(Jekyll::Site).to receive(:new).and_return(site)

      allow(JekyllPlus::Config).to receive(:new).and_return(config)
      allow(config).to receive(:jekyll_config)

      allow(JekyllPlus::Builder::Adder).to receive(:new).and_return(adder)
      allow(JekyllPlus::Builder::Remover).to receive(:new).and_return(remover)
      allow(JekyllPlus::Builder::Modifier).to receive(:new).and_return(modifier)
      allow(JekyllPlus::Builder::Rebuilder).to receive(:new)
        .and_return(rebuilder)
    end

    describe '#build' do
      it 'rebuilds the site' do
        expect(rebuilder).to receive(:update)
        subject.build
      end
    end

    describe '#added' do
      it 'builds if needed' do
        expect(adder).to receive(:update)
        subject.added(%w(foo))
      end
    end

    describe '#modified' do
      it 'builds if needed' do
        expect(modifier).to receive(:update)
        subject.modified(%w(foo))
      end
    end

    describe '#removed' do
      it 'builds if needed' do
        expect(remover).to receive(:update)
        subject.removed(%w(foo))
      end
    end
  end
end

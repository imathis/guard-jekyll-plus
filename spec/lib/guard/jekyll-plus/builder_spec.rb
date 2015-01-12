require 'guard/compat/test/helper'

require 'guard/jekyll-plus/builder'

module Guard
  RSpec.describe Jekyllplus::Builder do
    let(:config) { instance_double(Jekyllplus::Config) }
    let(:site) { instance_double(Jekyll::Site) }
    let(:rebuilder) { instance_double(Jekyllplus::Builder::Rebuilder) }
    let(:modifier) { instance_double(Jekyllplus::Builder::Modifier) }
    let(:adder) { instance_double(Jekyllplus::Builder::Adder) }
    let(:remover) { instance_double(Jekyllplus::Builder::Remover) }

    subject { described_class.new(config) }

    before do
      allow(Jekyll::Site).to receive(:new).and_return(site)

      allow(Jekyllplus::Config).to receive(:new).and_return(config)
      allow(config).to receive(:jekyll_config)

      allow(Jekyllplus::Builder::Adder).to receive(:new).and_return(adder)
      allow(Jekyllplus::Builder::Remover).to receive(:new).and_return(remover)
      allow(Jekyllplus::Builder::Modifier).to receive(:new).and_return(modifier)
      allow(Jekyllplus::Builder::Rebuilder).to receive(:new)
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

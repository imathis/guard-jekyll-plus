require 'guard/compat/test/helper'
require 'guard/jekyll_plus'

RSpec.describe Guard::JekyllPlus do
  let(:server) { instance_double(Guard::JekyllPlus::Server) }
  let(:config) { instance_double(Guard::JekyllPlus::Config) }
  let(:builder) { instance_double(Guard::JekyllPlus::Builder) }

  before do
    allow(Guard::Compat::UI).to receive(:info)

    allow(Guard::JekyllPlus::Config).to receive(:new).and_return(config)
    allow(Guard::JekyllPlus::Server).to receive(:new).and_return(server)
    allow(Guard::JekyllPlus::Builder).to receive(:new).and_return(builder)

    allow(config).to receive(:info)
    allow(config).to receive(:source)
    allow(config).to receive(:destination)
  end

  describe '#initialize' do
    it 'sets up the configuration' do
      options = double('options')
      expect(Guard::JekyllPlus::Config).to receive(:new).with(options)
      described_class.new(options)
    end
  end

  describe '#start' do
    before do
      allow(config).to receive(:serve?)
      allow(builder).to receive(:build)
    end

    it 'processes the site' do
      expect(builder).to receive(:build)
      subject.start
    end

    context 'when not serving' do
      before do
        allow(config).to receive(:serve?).and_return(false)
      end

      it 'does not start the server' do
        expect(server).to_not receive(:start)
        subject.start
      end
    end

    context 'when serving' do
      before do
        allow(config).to receive(:serve?).and_return(true)
      end

      it 'starts the server' do
        expect(server).to receive(:start)
        subject.start
      end
    end
  end

  describe '#run_on_modifications' do
    before do
      allow(builder).to receive(:modified)
    end

    context 'with normal modifications' do
      before do
        allow(config).to receive(:config_file?).and_return(false)
      end

      it 'updates based on given paths' do
        paths = [double('paths')]
        expect(builder).to receive(:modified).with(paths)
        subject.run_on_modifications(paths)
      end
    end

    context 'with changed config' do
      before do
        allow(config).to receive(:config_file?).and_return(true)

        # after config changes
        allow(builder).to receive(:build)
        allow(server).to receive(:stop)
        allow(config).to receive(:reload)
        allow(config).to receive(:serve?).and_return(false)
      end

      it 'reloads config' do
        paths = [double('paths')]
        expect(builder).to receive(:reload)
        subject.run_on_modifications(paths)
      end
    end
  end

  describe '#run_on_additions' do
    it 'updates based on given paths' do
      paths = [double('paths')]
      expect(builder).to receive(:added).with(paths)
      subject.run_on_additions(paths)
    end
  end

  describe '#run_on_removals' do
    it 'updates based on given paths' do
      paths = [double('paths')]
      expect(builder).to receive(:removed).with(paths)
      subject.run_on_removals(paths)
    end
  end
end

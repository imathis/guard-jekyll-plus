require 'guard/jekyll_plus/server'

# stub for tests to avoid requiring
unless Object.const_defined?(:Rack)
  module Rack
    class Handler
      class Thin
      end
    end

    class Server
      def initialize(_options)
      end

      def server
      end

      def start
      end
    end
  end
end

RSpec.describe Guard::JekyllPlus::Server do
  let(:config) { instance_double(Guard::JekyllPlus::Config) }
  subject { described_class.new(config) }

  before do
    allow(Thread).to receive(:new) do |&block|
      block.call
    end

    allow(Process).to receive(:fork) do |&block|
      block.call
    end

    allow(Process).to receive(:wait)
    allow(Process).to receive(:kill)

    allow_any_instance_of(Rack::Server).to receive(:start)
    allow(Jekyll::Commands::Serve).to receive(:process)
  end

  describe '#start' do
    before do
      allow(config).to receive(:host)
      allow(config).to receive(:baseurl)
      allow(config).to receive(:port)
      allow(config).to receive(:info)
      allow(config).to receive(:jekyll_serve_options)
    end

    context 'when Rack is available' do
      before do
        allow(Kernel).to receive(:require)
        allow(config).to receive(:server_root)
        allow(config).to receive(:rack_config)
        allow(config).to receive(:rack_environment)
        allow(File).to receive(:exist?).with('config.ru').and_return(false)
      end

      it 'starts the Rack server' do
        expect_any_instance_of(Rack::Server).to receive(:start)
        subject.start
      end
    end

    context 'when Rack is not available' do
      before do
        allow(Kernel).to receive(:require).and_raise(LoadError)
      end

      it 'starts the Jekyll server' do
        expect(Jekyll::Commands::Serve).to receive(:process)
        subject.start
      end
    end
  end
end

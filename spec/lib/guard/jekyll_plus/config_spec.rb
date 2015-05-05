require 'guard/compat/test/helper'

require 'guard/jekyll_plus/config'

RSpec.describe Guard::JekyllPlus::Config do
  let(:options) { {} }
  subject { described_class.new(options) }

  let(:valid_jekyll_options) do
    {
      'source' => 'foo',
      'destination' => 'bar'
    }
  end

  let(:jekyll_config) { valid_jekyll_options }

  before do
    allow(Jekyll).to receive(:configuration).and_return(jekyll_config)
  end

  describe '#source' do
    context 'with a relative path' do
      let(:jekyll_config) { valid_jekyll_options.merge('source' => 'foo') }

      it 'returns source from Jekyll config' do
        expect(subject.source).to eq('foo')
      end
    end
  end

  describe '#serve?' do
    context 'when option is not configured' do
      let(:options) { {} }
      it { is_expected.to_not be_serve }
    end

    context 'when configured as false' do
      let(:options) { { serve: false } }
      it { is_expected.to_not be_serve }
    end

    context 'when configuerd as true' do
      let(:options) { { serve:  true } }
      it { is_expected.to be_serve }
    end
  end

  %w(host baseurl port).each do |option|
    describe "#{option}" do
      let(:value) { double('value') }
      let(:jekyll_config) { valid_jekyll_options.merge(option.to_s => value) }

      it 'returns value from Jekyll config' do
        expect(subject.send(option)).to be(value)
      end
    end
  end

  describe '#jekyll_serve_options' do
    it 'returns all jekyll options'do
      expect(subject.jekyll_serve_options).to be(jekyll_config)
    end
  end

  describe '#server_root' do
    let(:path) { File.join(Dir.pwd, 'foo') }
    let(:jekyll_config) { valid_jekyll_options.merge('destination' => path) }

    it 'returns destination dir'do
      expect(subject.server_root).to eq('foo')
    end
  end

  describe '#rack_config' do
    context 'when option is not configured' do
      let(:options) { {} }
      it 'returns nil' do
        expect(subject.rack_config).to be_nil
      end
    end

    context 'when configured' do
      let(:rack_options) { double('rack options') }
      let(:options) { { rack_config: rack_options } }

      it 'returns value from options' do
        expect(subject.rack_config).to be(rack_options)
      end
    end
  end

  describe '#extensions' do
    let(:options) { { extensions: %w(foo) } }
    let(:exts) do
      'foo|md|mkd|mkdn|markdown|textile|html|haml|slim|xml|yml|sass|scss'
    end

    it 'returns configured extensions' do
      expect(subject.extensions).to eq(/\.(?:#{exts})$/i)
    end

    it 'matches .slim files' do
      expect(subject.extensions).to match('foo.slim')
    end
  end

  # We need this basically to turn off logging
  describe '#rack_environment' do
    context 'when silent is true' do
      let(:options) { { silent: true } }
      it 'uses nil to prevent loading Rack default middleware' do
        expect(subject.rack_environment).to eq(nil)
      end
    end

    context 'when silent is false' do
      let(:options) { { silent:  false } }
      it 'uses development for full Rack default middleware' do
        expect(subject.rack_environment).to eq('development')
      end
    end
  end

  describe '#excluded?' do
    context 'with excludes in Jekyll' do
      let(:jekyll_config) do
        valid_jekyll_options.merge('exclude' => ['f*', 'b*z'])
      end

      it 'matches files excluded in Jekyll' do
        expect(subject.excluded?('foo')).to be_truthy
        expect(subject.excluded?('bar')).to be_falsey
        expect(subject.excluded?('baz')).to be_truthy
      end
    end
  end

  describe '#watch_regexp' do
    context 'with a destination' do
      let(:jekyll_config) do
        valid_jekyll_options.merge('destination' => 'public')
      end

      it 'matches files outside destination' do
        expect(subject.watch_regexp).to match('foo')
        expect(subject.watch_regexp).to match('foo/bar')
        expect(subject.watch_regexp).to match('foo/public/bar')
        expect(subject.watch_regexp).to match('foo/public')
        expect(subject.watch_regexp).to match('publics/bar')
      end

      it 'does not match files in destination' do
        expect(subject.watch_regexp).to_not match('public/foo')
        expect(subject.watch_regexp).to_not match('public/foo/bar')
        expect(subject.watch_regexp).to_not match('public/foo/public')
      end
    end
  end
end

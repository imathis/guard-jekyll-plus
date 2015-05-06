require 'guard/jekyll_plus/builder/modifier'

module Guard
  RSpec.describe JekyllPlus::Builder::Modifier do
    let(:site) { instance_double(Jekyll::Site) }
    let(:config) { instance_double(JekyllPlus::Config) }
    subject { described_class.new(config, site) }

    describe '#update' do
      let(:extensions) { /\.haml$/i }

      before do
        # for build
        allow(config).to receive(:info)
        allow(config).to receive(:source)
        allow(config).to receive(:destination)

        allow(config).to receive(:extensions).and_return(extensions)
        allow(FileUtils).to receive(:mkdir_p)
        allow(FileUtils).to receive(:cp)
        allow($stdout).to receive(:puts)
      end

      context 'when source files change' do
        it 'builds' do
          expect(site).to receive(:process)
          subject.update(%w(foo.haml))
        end
      end

      context 'when assets change' do
        before do
          allow(config).to receive(:destination).and_return('bar/')
          allow(config).to receive(:source).and_return('.')
          allow(config).to receive(:excluded?).with('foo.jpg').and_return(false)
        end

        it 'copies files' do
          expect(FileUtils).to receive(:cp).with('foo.jpg', 'bar/foo.jpg')
          subject.update(%w(foo.jpg))
        end
      end

      context 'when excluded file changes' do
        before do
          allow(config).to receive(:destination).and_return('bar/')
          allow(config).to receive(:source).and_return('.')
          allow(config).to receive(:excluded?).with('foo.jpg').and_return(true)
        end

        it 'does not copy anything' do
          expect(FileUtils).to_not receive(:cp)
          subject.update(%w(foo.jpg))
        end

        it 'shows which files were excluded' do
          expect($stdout).to receive(:puts)
            .with(/Ignoring excluded file: foo\.jpg/)
          subject.update(%w(foo.jpg))
        end
      end

      # NOTE: Jekyll just shows a message and passes the plugin,
      # so it can fail with almost any possible exception.
      #
      # We catch StandardError to at least be somewhat reasonable
      context 'when an Jekyll conversion error happens' do
        before do
          allow(site).to receive(:process)
            .and_raise(NoMethodError, 'error evaluating Haml file')

          allow(config).to receive(:error)
        end

        it 'shows an error' do
          expect(config).to receive(:error).with('build has failed')
          expect(config).to receive(:error).with(/error evaluating Haml file/)

          catch(:task_has_failed) do
            subject.update(%w(foo.haml))
          end
        end

        it 'throws task_has_failed symbol' do
          expect do
            subject.update(%w(foo.haml))
          end.to throw_symbol(:task_has_failed)
        end
      end

      context 'when an error happens' do
        before do
          allow(config).to receive(:destination).and_return('bar/')
          allow(config).to receive(:source).and_return('.')
          allow(FileUtils).to receive(:cp).and_raise(Errno::ENOENT, 'foo')
          allow(config).to receive(:error)
          allow(config).to receive(:excluded?).with('foo').and_return(false)
        end

        it 'shows an error' do
          expect(config).to receive(:error).with('update has failed')
          expect(config).to receive(:error).with(/No such file.* - foo/)
          catch(:task_has_failed) do
            subject.update(%w(foo))
          end
        end

        it 'throws task_has_failed symbol' do
          expect do
            subject.update(%w(foo))
          end.to throw_symbol(:task_has_failed)
        end
      end
    end
  end
end

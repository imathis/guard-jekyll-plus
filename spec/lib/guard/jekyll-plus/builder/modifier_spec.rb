require 'guard/jekyll-plus/builder/modifier'

module Guard
  RSpec.describe Jekyllplus::Builder::Modifier do
    let(:site) { instance_double(Jekyll::Site) }
    let(:config) { instance_double(Jekyllplus::Config) }
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
        end

        it 'copies files' do
          expect(FileUtils).to receive(:cp).with('foo.jpg', 'bar/foo.jpg')
          subject.update(%w(foo.jpg))
        end
      end

      context 'when an error happens' do
        before do
          allow(config).to receive(:destination).and_return('bar/')
          allow(FileUtils).to receive(:cp).and_raise(Errno::ENOENT, 'foo')
          allow(config).to receive(:error)
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

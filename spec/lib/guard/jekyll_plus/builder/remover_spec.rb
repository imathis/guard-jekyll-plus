require 'guard/jekyll_plus/builder/remover'

module Guard
  RSpec.describe JekyllPlus::Builder::Remover do
    let(:site) { instance_double(Jekyll::Site) }
    let(:config) { instance_double(JekyllPlus::Config) }
    subject { described_class.new(config, site) }

    describe '#update' do
      let(:extensions) { /\.haml$/i }

      before do
        allow(config).to receive(:extensions).and_return(extensions)

        # for build
        allow(config).to receive(:info)
        allow(config).to receive(:source)
        allow(config).to receive(:destination)

        allow($stdout).to receive(:puts)
      end

      context 'when asset files are deleted' do
        before do
          allow(config).to receive(:destination).and_return('bar/')
          allow(config).to receive(:source).and_return('.')

          # non existing src file
          allow(File).to receive(:exist?).with('foo.jpg').and_return(false)

          # Make one file exist so removing dst files can happen.
          # I'm not sure why this is necessary
          allow(File).to receive(:exist?).with('logo.png').and_return(true)

          # existing destination file
          allow(File).to receive(:exist?).with('bar/foo.jpg').and_return(true)

          # the removing of the file
          allow(FileUtils).to receive(:rm).with('bar/foo.jpg')
          allow(FileUtils).to receive(:rm).with('bar/logo.png')

          # checking for empty dirs to clear
          allow(Dir).to receive(:[]).with('bar/*').and_return(%w(logo.png))
          allow(File).to receive(:exist?).with('bar/logo.png').and_return(true)
        end

        it 'removes delete files from destination' do
          expect(FileUtils).to receive(:rm).with('bar/foo.jpg')
          subject.update(%w(foo.jpg logo.png))
        end
      end

      context 'when sources files are removed' do
        it 'builds' do
          expect(site).to receive(:process)
          subject.update(%w(foo.haml))
        end
      end

      context 'when an error happens' do
        before do
          allow(config).to receive(:destination).and_return('bar/')
          allow(config).to receive(:source).and_return('.')

          allow(config).to receive(:error)
          allow(File).to receive(:exist?).with('foo').and_return(false)

          # just so the removing is triggered (don't know why)
          allow(File).to receive(:exist?).with('baz').and_return(true)

          # file to be deleted
          allow(File).to receive(:exist?).with('bar/foo').and_return(true)

          # file we don't care about
          allow(File).to receive(:exist?).with('bar/baz').and_return(false)

          allow(Dir).to receive(:[]).with('bar/*').and_return(%w(logo.png))

          # simulate failure
          allow(FileUtils).to receive(:rm).with('bar/foo')
            .and_raise(Errno::ENOENT, 'foo')
        end

        it 'shows an error' do
          expect(config).to receive(:error).with('remove has failed')
          expect(config).to receive(:error).with(/No such file.* - foo/)
          catch(:task_has_failed) do
            subject.update(%w(foo baz))
          end
        end

        it 'throws task_has_failed symbol' do
          expect do
            subject.update(%w(foo baz))
          end.to throw_symbol(:task_has_failed)
        end
      end
    end
  end
end

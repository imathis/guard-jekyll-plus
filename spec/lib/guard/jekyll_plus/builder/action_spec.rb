require 'guard/jekyll_plus/builder/action'
module Guard
  RSpec.describe JekyllPlus::Builder::Action do
    let(:site) { instance_double(Jekyll::Site) }
    let(:config) { instance_double(JekyllPlus::Config) }

    subject { described_class.new(config, site) }

    describe '#destination_path' do
      let(:source) { '/foo/project' }

      before do
        allow(config).to receive(:destination).and_return(destination)
        allow(config).to receive(:source).and_return(source)
        allow_any_instance_of(Pathname).to receive(:expand_path) do |path|
          case path
          when Pathname('/foo/project')
            Pathname('/foo/project')
          when Pathname('bar/file.html')
            Pathname('/foo/project/bar/file.html')
          when Pathname('/foo/project/bar/file.html')
            Pathname('/foo/project/bar/file.html')
          else
            fail "Unexpected path: #{path.inspect}"
          end
        end
      end

      context 'when destination is absolute ' do
        let(:destination) { '/foo/project/public' }
        let(:expected) { '/foo/project/public/bar/file.html' }

        context 'when file is absolute' do
          let(:file) { '/foo/project/bar/file.html' }
          it 'is absolute' do
            expect(subject.destination_path(file)).to eq expected
          end
        end

        context 'when file is relative' do
          let(:file) { 'bar/file.html' }
          it 'is absolute' do
            expect(subject.destination_path(file)).to eq expected
          end
        end
      end

      context 'when destination is relative' do
        let(:destination) { 'public' }
        let(:expected) { 'public/bar/file.html' }

        context 'when file is absolute' do
          let(:file) { '/foo/project/bar/file.html' }
          it 'is relative ' do
            expect(subject.destination_path(file)).to eq expected
          end
        end

        context 'when file is relative' do
          let(:file) { 'bar/file.html' }
          it 'is relative ' do
            expect(subject.destination_path(file)).to eq expected
          end
        end
      end
    end
  end
end

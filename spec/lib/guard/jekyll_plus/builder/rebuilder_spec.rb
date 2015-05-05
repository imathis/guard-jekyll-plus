require 'guard/jekyll_plus/builder/rebuilder'

module Guard
  RSpec.describe JekyllPlus::Builder::Rebuilder do
    let(:site) { instance_double(Jekyll::Site) }
    let(:config) { instance_double(JekyllPlus::Config) }
    subject { described_class.new(config, site) }

    describe '#update' do
      before do
        allow(site).to receive(:process)
        allow($stdout).to receive(:puts)
        allow(config).to receive(:info)
        allow(config).to receive(:source)
        allow(config).to receive(:destination)
      end

      it 'processes all the files' do
        expect(site).to receive(:process)
        subject.update
      end

      it 'shows header' do
        expect(config).to receive(:info).with(/building\.\.\./)
        subject.update
      end

      # NOTE: Jekyll just shows a message and passes the plugin,
      # so it can fail with almost any possible exception.
      #
      # We catch StandardError to at least be somewhat reasonable
      context 'when an Jekyll conversion error happens' do
        before do
          allow(config).to receive(:error)
          allow(site).to receive(:process)
            .and_raise(NoMethodError, 'something in Haml template failed')
        end

        it 'shows an error' do
          expect(config).to receive(:error).with('build has failed')
          expect(config).to receive(:error).with(/something in Haml template/)
          catch(:task_has_failed) do
            subject.update
          end
        end

        it 'throws task_has_failed symbol' do
          expect do
            subject.update
          end.to throw_symbol(:task_has_failed)
        end
      end

      context 'when a system error happens' do
        before do
          allow(config).to receive(:error)
          allow(site).to receive(:process).and_raise(RuntimeError, 'big error')
        end

        it 'shows an error' do
          expect(config).to receive(:error).with('build has failed')
          expect(config).to receive(:error).with(/big error/)
          catch(:task_has_failed) do
            subject.update
          end
        end

        it 'throws task_has_failed symbol' do
          expect do
            subject.update
          end.to throw_symbol(:task_has_failed)
        end
      end
    end
  end
end

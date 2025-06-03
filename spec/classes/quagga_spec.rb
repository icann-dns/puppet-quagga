# frozen_string_literal: true

require 'spec_helper'

describe 'frr' do
  # by default the hiera integration uses hiera data from the shared_contexts.rb file
  # but basically to mock hiera you first need to add a key/value pair
  # to the specific context in the spec/shared_contexts.rb file
  # Note: you can only use a single hiera context per describe/context block
  # rspec-puppet does not allow you to swap out hiera data on a per test block
  # include_context :hiera

  # below is the facts hash that gives you the ability to mock
  # facts on a per describe/context block.  If you use a fact in your
  # manifest you should mock the facts below.
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end
      # below is a list of the resource parameters that you can override.
      # By default all non-required parameters are commented out,
      # while all required parameters will require you to add a value
      let(:params) do
        {
          # :owner => "frr",
          # :group => "frr",
          # :mode => "0664",
          # :package => "frr",
          # :enable => true,
          content: 'hostname test',
        }
      end

      describe 'check default parameters' do
        # add these two lines in a single test block to enable puppet and hiera debug mode
        # Puppet::Util::Log.level = :debug
        # Puppet::Util::Log.newdestination(:console)
        it do
          is_expected.to compile.with_all_deps
        end

        it { is_expected.to contain_package('frr') }
        it { is_expected.to contain_class('Frr') }

        it do
          is_expected.to contain_file('/etc/frr/zebra.conf').with(
            content: 'hostname test',
            ensure: 'file',
            group: 'frr',
            mode: '0664',
            notify: 'Service[zebra]',
            owner: 'frr'
          )
        end

        it do
          is_expected.to contain_file('/usr/local/bin/frr_status.sh').with(
            content: %r{pgrep -u frr},
            ensure: 'file',
            mode: '0555'
          )
        end

        it do
          is_expected.to contain_file('/etc/profile.d/vtysh.sh').with(
            ensure: 'file',
            source: 'puppet:///modules/frr/vtysh.sh'
          )
        end

        it do
          is_expected.to contain_service('zebra').with(
            enable: 'true',
            ensure: 'running'
          )
        end

        it do
          is_expected.to contain_ini_setting('zebra').with(
            setting: 'zebra',
            value: 'yes'
          )
        end
      end

      describe 'check changin default parameters' do
        context 'owner' do
          before { params.merge!(owner: 'foo') }

          it { is_expected.to contain_file('/etc/frr/zebra.conf').with_owner('foo') }

          it do
            is_expected.to contain_file(
              '/usr/local/bin/frr_status.sh'
            ).with_content(
              %r{pgrep -u foo}
            )
          end
        end

        context 'group' do
          before { params.merge!(group: 'foo') }

          it { is_expected.to contain_file('/etc/frr/zebra.conf').with_group('foo') }
        end

        context 'mode' do
          before { params.merge!(mode: '0600') }

          it { is_expected.to contain_file('/etc/frr/zebra.conf').with_mode('0600') }
        end

        context 'package' do
          before { params.merge!(package: 'foo') }

          it { is_expected.to contain_package('foo') }
        end

        context 'enable' do
          before { params.merge!(enable: false) }

          it do
            is_expected.to contain_ini_setting('zebra').with(
              setting: 'zebra',
              value:   'no'
            )
          end
        end

        context 'content' do
          before { params.merge!(content: 'foo') }

          it do
            is_expected.to contain_file('/etc/frr/zebra.conf').with_content(
              %r{foo}
            )
          end
        end
      end

      describe 'check bad parameters' do
        context 'owner' do
          before { params.merge!(owner: true) }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'group' do
          before { params.merge!(group: []) }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'mode' do
          before { params.merge!(mode: 'foo') }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'package' do
          before { params.merge!(package: {}) }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'enable' do
          before { params.merge!(enable: 'false') }

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'content' do
          before { params.merge!(content: []) }

          it { is_expected.to raise_error(Puppet::Error) }
        end
      end
    end
  end
end

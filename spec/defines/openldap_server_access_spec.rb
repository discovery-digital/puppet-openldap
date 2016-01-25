require 'spec_helper'

describe 'openldap::server::access' do

  let(:title) { 'foo' }

  let :pre_condition do
    "class {'openldap::server':}"
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      context 'when Class[openldap::server] is not declared' do
        let(:pre_condition) { }
        let(:params) {{ :access => 'manage' }}
        it { expect { is_expected.to compile }.to raise_error(/class ::openldap::server has not been evaluated/) }
      end

      context 'with composite namevar' do
        let(:title) {
          '{0}to attrs=userPassword,shadowLastChange on dc=example,dc=com'
        }
        let(:params) {{ :access => 'manage' }}
        it { is_expected.to compile.with_all_deps }
        it {
          skip('Should work')
          is_expected.to contain_openldap_access('to attrs=userPassword,shadowLastChange on dc=example,dc=com').that_requires('Openldap_database[dc=example,dc=com]')
        }
      end
    end
  end
end

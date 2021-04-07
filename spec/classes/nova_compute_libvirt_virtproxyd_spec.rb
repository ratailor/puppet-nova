# Unit tests for nova::compute::libvirt::virtproxyd class
#
require 'spec_helper'

describe 'nova::compute::libvirt::virtproxyd' do

  let :pre_condition do
    <<-eos
    include nova
    include nova::compute
    include nova::compute::libvirt
eos
  end

  shared_examples_for 'nova-compute-libvirt-virtproxyd' do

    context 'with default parameters' do
      let :params do
        {}
      end

      it { is_expected.to contain_class('nova::deps')}
      it { is_expected.to contain_class('nova::compute::libvirt::virtproxyd')}

      it { is_expected.to contain_virtproxyd_config('log_level').with_ensure('absent')}
      it { is_expected.to contain_virtproxyd_config('log_outputs').with_ensure('absent')}
      it { is_expected.to contain_virtproxyd_config('log_filters').with_ensure('absent')}
      it { is_expected.to contain_virtproxyd_config('max_clients').with_ensure('absent')}
      it { is_expected.to contain_virtproxyd_config('admin_max_clients').with_ensure('absent')}
      it { is_expected.to contain_virtproxyd_config('ovs_timeout').with_ensure('absent')}
      it { is_expected.to contain_virtproxyd_config('tls_priority').with_ensure('absent')}
    end

    context 'with specified parameters' do
      let :params do
        { :log_level         => 3,
          :log_outputs       => '3:syslog',
          :log_filters       => '1:logging 4:object 4:json 4:event 1:util',
          :max_clients       => 1024,
          :admin_max_clients => 5,
          :ovs_timeout       => 10,
          :tls_priority      => 'NORMAL:-VERS-SSL3.0',
        }
      end

      it { is_expected.to contain_class('nova::deps')}
      it { is_expected.to contain_class('nova::compute::libvirt::virtproxyd')}

      it { is_expected.to contain_virtproxyd_config('log_level').with_value(params[:log_level])}
      it { is_expected.to contain_virtproxyd_config('log_outputs').with_value("\"#{params[:log_outputs]}\"")}
      it { is_expected.to contain_virtproxyd_config('log_filters').with_value("\"#{params[:log_filters]}\"")}
      it { is_expected.to contain_virtproxyd_config('max_clients').with_value(params[:max_clients])}
      it { is_expected.to contain_virtproxyd_config('admin_max_clients').with_value(params[:admin_max_clients])}
      it { is_expected.to contain_virtproxyd_config('ovs_timeout').with_value(params[:ovs_timeout])}
      it { is_expected.to contain_virtproxyd_config('tls_priority').with_value("\"#{params[:tls_priority]}\"")}
    end
  end

  on_supported_os({
     :supported_os => OSDefaults.get_supported_os
   }).each do |os,facts|
     context "on #{os}" do
       let (:facts) do
         facts.merge!(OSDefaults.get_facts())
       end

       it_configures 'nova-compute-libvirt-virtproxyd'
     end
  end

end

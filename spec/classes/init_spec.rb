require 'spec_helper'
describe 'krb5' do

  context 'with defaults for all parameters on RedHat' do
    let(:facts) do { :osfamily => 'RedHat', } end
    it { should contain_class('krb5') }
    it { should contain_package('krb5-libs') }
    it { should contain_file('krb5conf').with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'root',
      'mode'   => '0644',
      'content' => '#Managed by puppet, any changes will be overwritten

[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log
',})}
  end
  context 'with defaults for all parameters on Suse' do
    let(:facts) do { :osfamily => 'Suse', } end
    it { should contain_class('krb5') }
    it { should contain_package('krb5') }
  end
  context 'on unsupported osfamily' do
    let(:facts) do { :osfamily => 'Debian', } end
    it 'should fail' do
      expect {
        should contain_class('krb5')
      }.to raise_error(Puppet::Error,/krb5 only supports default package names for RedHat and Suse./)
    end
  end
  context 'on unsupported osfamily with package set' do
    let(:facts) do { :osfamily => 'Debian', } end
    let(:params) do { :package => 'krb5-package', } end
    it { should contain_package('krb5-package') }
  end
  context 'with all parameters set' do
    let(:params) do
      { :default_realm        => 'EXAMPLE.COM',
        :dns_lookup_realm     => 'false',
        :dns_lookup_kdc       => 'false',
        :ticket_lifetime      => '24h',
        :default_keytab_name  => '/etc/opt/quest/vas/host.keytab',
        :forwardable          => 'true',
        :proxiable            => 'true',
        :realms               => {
          'EXAMPLE.COM'       => {
            'default_domain'  => 'example.com',
            'kdc'             => [ 'kdc1.example.com:88', 'kdc2.example.com:88', ],
            'admin_server'    => [ 'kdc1.example.com:749', 'kdc2.example.com:749', ],
          },
        },
        :appdefaults          => {
          'pam' => {
            'debug'           => 'false',
            'ticket_lifetime' => '36000',
            'renew_lifetime'  => '36000',
            'forwardable'     => 'true',
            'krb4_convert'    => 'false',
          },
        },
        :domain_realm         => {
          'example.com'       => 'EXAMPLE.COM',
        },
        :package              => 'krb5-package',
      }
    end
    it { should contain_file('krb5conf').with({
      'content' => '#Managed by puppet, any changes will be overwritten

[logging]
default = FILE:/var/log/krb5libs.log
kdc = FILE:/var/log/krb5kdc.log
admin_server = FILE:/var/log/kadmind.log

[libdefaults]
default_realm = EXAMPLE.COM
dns_lookup_realm = false
dns_lookup_kdc = false
ticket_lifetime = 24h
default_keytab_name = /etc/opt/quest/vas/host.keytab
forwardable = true
proxiable = true

[appdefaults]
pam = {
         debug = false
         forwardable = true
         krb4_convert = false
         renew_lifetime = 36000
         ticket_lifetime = 36000
}

[realms]
EXAMPLE.COM = {
  kdc = kdc1.example.com:88
  kdc = kdc2.example.com:88
  admin_server = kdc1.example.com:749
  admin_server = kdc2.example.com:749
  default_domain = example.com
}

[domain_realm]
.example.com = EXAMPLE.COM
example.com = EXAMPLE.COM
'}) }
    it { should contain_package('krb5-package') }
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "Trocla::Encryptions::Ssl" do

  before(:all) do
    generate_ssl_keys
  end

  after(:all) do
    remove_ssl_keys
  end

  before(:each) do
    expect_any_instance_of(Trocla).to receive(:read_config).and_return(ssl_test_config)
    @trocla = Trocla.new
  end

  after(:each) do
    remove_yaml_store
  end

  describe "encrypt" do
    it "should be able to store random passwords" do
      @trocla.password('random1', 'plain').length.should eql(16)
    end

    it "should be able to store long random passwords" do
      @trocla.set_password('random1_long','plain',4096.times.collect{|s| 'x' }.join('')).length.should eql(4096)
    end

    it "should be able to retrieve stored random passwords" do
      stored = @trocla.password('random1', 'plain')
      retrieved = @trocla.password('random1', 'plain')
      retrieved_again = @trocla.password('random1', 'plain')
      retrieved.should eql(stored)
      retrieved_again.should eql(stored)
    end

    it "should be able to read encrypted passwords" do
      @trocla.set_password('some_pass', 'plain', 'super secret')
      @trocla.get_password('some_pass', 'plain').should eql('super secret')
    end

    it "should not store plaintext passwords" do
      @trocla.set_password('noplain', 'plain', 'plaintext_password')
      File.readlines(trocla_yaml_file).grep(/plaintext_password/).should be_empty
    end

    it "should make sure identical passwords do not match when stored" do
      @trocla.set_password('one_key', 'plain', 'super secret')
      @trocla.set_password('another_key', 'plain', 'super secret')
      yaml = YAML.load_file(trocla_yaml_file)
      yaml['one_key']['plain'].should_not eql(yaml['another_key']['plain'])
    end
  end
end

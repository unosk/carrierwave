require 'spec_helper'

describe CarrierWave::Uploader do
  before do
    @uploader_class = Class.new(CarrierWave::Uploader::Base)
    @uploader = @uploader_class.new
  end

  after do
    FileUtils.rm_rf(public_path)
  end

  describe '#cache!' do

    before do
      allow(CarrierWave).to receive(:generate_cache_id).and_return('1369894322-345-1234-2255')
    end

    it "should not raise an integrity error if there is no blacklist" do
      allow(@uploader).to receive(:extension_blacklist).and_return(nil)
      expect(running {
        @uploader.cache!(File.open(file_path('test.jpg')))
      }).not_to raise_error
    end

    it "should raise an integrity error if there is a blacklist and the file is on it" do
      allow(@uploader).to receive(:extension_blacklist).and_return(%w(jpg gif png))
      expect(running {
        @uploader.cache!(File.open(file_path('test.jpg')))
      }).to raise_error(CarrierWave::IntegrityError)
    end

    it "should not raise an integrity error if there is a blacklist and the file is not on it" do
      allow(@uploader).to receive(:extension_blacklist).and_return(%w(txt doc xls))
      expect(running {
        @uploader.cache!(File.open(file_path('test.jpg')))
      }).not_to raise_error
    end

    it "should not raise an integrity error if there is a blacklist and the file is not on it, using start of string matcher" do
      allow(@uploader).to receive(:extension_blacklist).and_return(%w(txt))
      expect(running {
        @uploader.cache!(File.open(file_path('bork.ttxt')))
      }).not_to raise_error
    end

    it "should not raise an integrity error if there is a blacklist and the file is not on it, using end of string matcher" do
      allow(@uploader).to receive(:extension_blacklist).and_return(%w(txt))
      expect(running {
        @uploader.cache!(File.open(file_path('bork.txtt')))
      }).not_to raise_error
    end

    it "should compare blacklist in a case insensitive manner when capitalized extension provided" do
      allow(@uploader).to receive(:extension_blacklist).and_return(%w(jpg gif png))
      expect(running {
        @uploader.cache!(File.open(file_path('case.JPG')))
      }).to raise_error(CarrierWave::IntegrityError)
    end

    it "should compare blacklist in a case insensitive manner when lowercase extension provided" do
      allow(@uploader).to receive(:extension_blacklist).and_return(%w(JPG GIF PNG))
      expect(running {
        @uploader.cache!(File.open(file_path('test.jpg')))
      }).to raise_error(CarrierWave::IntegrityError)
    end

    it "should accept and check regular expressions" do
      allow(@uploader).to receive(:extension_blacklist).and_return([/jpe?g/, 'gif', 'png'])
      expect(running {
        @uploader.cache!(File.open(file_path('test.jpeg')))
      }).to raise_error(CarrierWave::IntegrityError)
    end
  end

end

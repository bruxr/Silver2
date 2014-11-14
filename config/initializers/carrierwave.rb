CarrierWave.configure do |config|
  fog_config = YAML.load(ERB.new(File.read(Rails.root.join('config', 'fog.yml'))).result)
  fog_config = fog_config['default'].symbolize_keys
  config.fog_credentials = fog_config
  config.fog_directory = Rails.application.secrets.s3_bucket
end
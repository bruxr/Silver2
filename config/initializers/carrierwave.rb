Fog.credentials_path = Rails.root.join('config', 'fog.yml')

CarrierWave.configure do |config|
  config.fog_credentials = { provider: 'AWS' }
  config.fog_directory = 'silver.bruxromuar.com'
end
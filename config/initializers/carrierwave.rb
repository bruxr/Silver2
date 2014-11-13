CarrierWave.configure do |config|
  config.fog_credentials = {
    provider: 'AWS',
    aws_access_key_id: Rails.application.secrets.s3_key,
    aws_secret_access_key: Rails.application.secrets.s3_secret,
    region: 'ap-northeast-1',
    path_style: true
  }
  config.fog_directory = 'silver.bruxromuar.com'
end
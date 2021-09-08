#Seed Satellites
[
  {name: 'snpp',   norad_name: 'SUOMI NPP' },
  {name: 'aqua',   norad_name: 'AQUA' },
  {name: 'terra',  norad_name: 'TERRA' },
  {name: 'noaa15', norad_name: 'NOAA 15' },
  {name: 'noaa18', norad_name: 'NOAA 18' },
  {name: 'noaa19', norad_name: 'NOAA 19' },
  {name: 'noaa20', norad_name: 'NOAA 20' },
  {name: 'metop-b', norad_name: 'METOP-B' }, 
  {name: 'metop-c', norad_name: 'METOP-C' },
].each do |satellite|
  Satellite.where(name: satellite[:name]).first_or_create(norad_name: satellite[:norad_name])
end

# Seed Sensors
s = Sensor.where(name: 'modis').first_or_create do |s|
  s.satellites = Satellite.where(name: ['aqua','terra'])
end

%w{viirs cris atms omps}.each do |sensor|
  s = Sensor.where(name: sensor).first_or_create do |s|
    s.satellites << Satellite.where(name: 'snpp')
    s.satellites << Satellite.where(name: 'noaa20')
  end
end

s = Sensor.where(name: 'avhrr').first_or_create do |s|
  s.satellites = Satellite.where(name: %w{15 18 19}.map{|ii| "noaa#{ii}"})
  s.satellites << Satellite.where(name: 'metop-b')
  s.satellites << Satellite.where(name: 'metop-c')
end

#Seed Facilities
%w{gilmore uafgina barrow}.each do |fac|
  Facility.where(name: fac).first_or_create
end

#Seed Processing Levels
%w{raw level0 level1 level2 tdf awips geotiff}.each do |l|
  ProcessingLevel.where(name: l).first_or_create
end

#Seed requirements
%w{rt-stps cspp_sdr viirs_edr ldm uw-hyperspectral polar2grid polar2grid-2 gdal terascan aapp}.each do |requirement|
  Requirement.where(name: requirement).first_or_create
end

if Rails.env.development? && SiteConfig.count == 0
  SiteConfig.where(name: 'GINA::NRT Dashboard', host: 'http://sandy-rails.127.0.0.1.xip.io').first_or_create
end

Notification.where(name: 'notifications.job_error').first_or_create do |n|
  n.description = 'Processing error'
end
Notification.where(name: 'notifications.paused_queues').first_or_create do |n|
  n.description = 'Queues paused'
end
Notification.where(name: 'notifications.resumed_queues').first_or_create do |n|
  n.description = 'Queues resumed'
end

#Seed Workflows
Dir.glob("./db/workflows/*.rb").each do |workflow|
  require workflow
  #eval(File.read(workflow))
end

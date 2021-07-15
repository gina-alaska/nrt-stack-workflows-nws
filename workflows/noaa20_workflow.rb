steps = {}

steps[:arrival] = Step.where(name: 'Noaa20Arrival').first_or_create({
  processing_level: ProcessingLevel.where(name: 'raw').first_or_create
})
steps[:rtstps] = Step.where(name: "Snoaa20RtstpsJob").first_or_create({
  command: "rtstps.rb -p noaa20 -t {{workspace}} {{job.input_file}} {{job.output_path}}",
  queue: 'rtstps',
  processing_level: ProcessingLevel.where(name: 'level0').first_or_create,
  parent: steps[:arrival]
})


#VIIRS SDR
steps[:viirs_sdr] = Step.where(name: "Noaa20ViirsSdrJob").first_or_create({
  command: "snpp_sdr.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: "cspp_sdr",
  processing_level: ProcessingLevel.where(name: 'level1').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:rtstps]
})

#VIIRS GEOTIFS
steps[:viirs_geotiff] = Step.where(name: "Noaa20ViirsGeoTiff").first_or_create({
  command: "p2g_geotif.rb -m viirs -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'geotiff',
  processing_level: ProcessingLevel.where(name: 'geotiff').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:viirs_sdr]
})

#VIIRS FEEDER Geotifs
steps[:viirs_feeder] = Step.where(name: "Noaa20ViirsFeeder").first_or_create({
  command: "feeder_geotif.rb -m noaa20 -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'geotiff',
  
  processing_level: ProcessingLevel.where(name: 'geotiff').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:viirs_geotiff]
})

#VIIRS SCMI
steps[:noaa20_viirs_scmi] = Step.where(name: 'NOAA20SnppViirsSCMI').first_or_create({
  enabled: true,
  queue: 'polar2grid',
  command: 'awips_scmi.rb -p 4 -m viirs -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "viirs").first_or_create,
  processing_level: ProcessingLevel.where(name: 'scmi').first_or_create,
  parent: steps[:viirs_sdr]
})

#VIIRS SCMI LDM
steps[:noaa20_viirs_scmi_ldm] = Step.where(name: 'NOAA20ViirsSCMILdmInject').first_or_create({
  command: 'pqinsert.rb -t . {{job.input_path}}',
  queue: 'ldm',
  producer: false,
  parent: steps[:noaa20_viirs_scmi],
  enabled: false
})

#ATMS
steps[:atms_sdr] = Step.where(name: 'Noaa20AtmsSdrJob').first_or_create({
  enabled: false,
  queue: 'cspp_sdr',
  command: 'snpp_sdr.rb -m atms -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'level1').first_or_create,
  parent: steps[:rtstps]
})

#---------------- NUCAPS
# SDR
steps[:nucaps_sdr] = Step.where(name: 'NOAA20NucapsSdrJob').first_or_create({
  enabled: true,
  queue: 'cspp_sdr',
  command: 'nucaps_sdr.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'nucaps_level1').first_or_create,
  parent: steps[:rtstps]
})

# L2
steps[:nucaps] = Step.where(name: 'NOAA20NucapsL2Job').first_or_create({
  enabled: true,
  queue: 'cspp_extras',
  command: 'nucaps_l2.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'nucaps_level2').first_or_create,
  parent: steps[:nucaps_sdr]
})

#LDM
steps[:noaa20_nucap_ldm] = Step.where(name: 'NOAA20NucapsLdmInject').first_or_create({
  command: 'pqinsert.rb -t . {{job.input_path}}',
  queue: 'ldm',
  producer: false,
  parent: steps[:nucaps],
  enabled: false
})

#-----------------  MIRS
# L2 MIRS
steps[:atms_mirs] = Step.where(name: 'Noaa20AtmsMirsJob').first_or_create({
  enabled: false,
  queue: 'cspp_extras',
  command: 'mirs_l0.rb -s noaa20 -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'mirs_level2').first_or_create,
  parent: steps[:atms_sdr]
})

#SCMI
steps[:atms_mirs_scmi] = Step.where(name: 'Noaa20AtmsMirsSCMIJob').first_or_create({
  enabled: false,
  queue: 'polar2grid',
  command: 'awips_scmi.rb -m mirs -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'mirs_scmi').first_or_create,
  parent: steps[:atms_mirs]
})

# SCMI LDM
steps[:atms_mirs_scmi_ldm] = Step.where(name: 'Noaa20AtmsMirsAwipsLdmInjectJob').first_or_create({
    command: 'pqinsert.rb -t . {{job.input_path}}',
    queue: 'ldm',
    producer: false,
    parent: steps[:atms_mirs_scmi],
    enabled: false
})

satellite = Satellite.friendly.find('noaa20')
satellite.workflows << steps[:arrival] unless satellite.workflows.include?(steps[:arrival])

steps = {}

steps[:arrival] = Step.where(name: 'SnppArrival').first_or_create({
  processing_level: ProcessingLevel.where(name: 'raw').first_or_create
})
steps[:rtstps] = Step.where(name: "SnppRtstpsJob").first_or_create({
  command: "rtstps.rb -p npp -t {{workspace}} {{job.input_file}} {{job.output_path}}",
  queue: 'rtstps',
  processing_level: ProcessingLevel.where(name: 'level0').first_or_create,
  parent: steps[:arrival]
})

steps[:viirs_sdr] = Step.where(name: "ViirsSdrJob").first_or_create({
  command: "snpp_sdr.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: "cspp_sdr",
  processing_level: ProcessingLevel.where(name: 'level1').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:rtstps]
})

#VIIRS SCMI
steps[:snpp_viirs_scmi] = Step.where(name: 'SnppViirsSCMI').first_or_create({
  enabled: false,
  queue: 'polar2grid',
  command: 'awips_scmi.rb -p 4 -m viirs -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "viirs").first_or_create,
  processing_level: ProcessingLevel.where(name: 'scmi').first_or_create,
  parent: steps[:viirs_sdr]
})

#VIIRS SCMI LDM
steps[:snpp_viirs_scmi_ldm] = Step.where(name: 'SnppViirsSCMILdmInject').first_or_create({
  command: 'pqinsert.rb -t . -s \"VIIRS_ALASK\" {{job.input_path}}',
  queue: 'ldm',
  producer: false,
  parent: steps[:snpp_viirs_scmi],
  enabled: false
})

#VIIRS Geotiff
steps[:viirs_geotiff] = Step.where(name: "ViirsGeoTiff").first_or_create({
  command: "p2g_geotif.rb -m viirs -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'geotiff_l1').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:viirs_sdr]
})

#VIIRS Geotiffs formatting for Feeder
steps[:viirs_feeder] = Step.where(name: "ViirsFeeder").first_or_create({
  command: "feeder_geotif.rb -m npp -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'geotiff',
  processing_level: ProcessingLevel.where(name: 'geotiff_level2').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:viirs_geotiff],
  producer: false,
  enabled: false
})

#ATMS
steps[:atms_sdr] = Step.where(name: 'AtmsSdrJob').first_or_create({
  enabled: false,
  queue: 'cspp_sdr',
  command: 'snpp_sdr.rb -m atms -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'level1').first_or_create,
  parent: steps[:rtstps]
})

#ATMS MIRS
steps[:atms_mirs] = Step.where(name: 'AtmsMirsJob').first_or_create({
  enabled: false,
  queue: 'cspp_extras',
  command: 'mirs_l0.rb -s atms -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'mirs_level2').first_or_create,
  parent: steps[:atms_sdr]
})

#MIRS SCMI
steps[:atms_mirs_scmi] = Step.where(name: 'AtmsMirsScmi').first_or_create({
  enabled: false,
  queue: 'polar2grid',
  command: 'awips_scmi.rb -m mirs -t {{workspace}} {{job.input_path}} {{job.output_path}}',
  sensor: Sensor.where(name: "atms").first_or_create,
  processing_level: ProcessingLevel.where(name: 'mirs_scmi').first_or_create,
  parent: steps[:atms_mirs]
})

#MIRS SCMI LDM
steps[:atms_mirs_scmi_ldm] = Step.where(name: 'AtmsMirsScmiLdmInjectJob').first_or_create({
    command: 'pqinsert.rb -t . {{job.input_path}}',
    queue: 'ldm',
    producer: false,
    parent: steps[:atms_mirs_scmi],
    enabled: false
})

satellite = Satellite.friendly.find('snpp')
satellite.workflows << steps[:arrival] unless satellite.workflows.include?(steps[:arrival])




#snpp
steps = {}
steps[:l1] = Step.where(name: "ViirsSdrJob").first

steps[:fire] = Step.where(name: "SNPPNoaaFire").first_or_create({
  command: "noaa_viirs_fire.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:l1]
})

steps[:convert] = Step.where(name: "SNPPNoaaFireConvert").first_or_create({
  command: "vaf_awips_reformat.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:fire]
})

steps[:ldm] = Step.where(name: "SNPPNoaaFireLDM").first_or_create({
  command: "pqinsert.rb -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:convert]
})

#noaa20
steps = {}
steps[:l1] = Step.where(name: "Noaa20ViirsSdrJob").first

steps[:fire] = Step.where(name: "N20NoaaFire").first_or_create({
  command: "noaa_viirs_fire.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'fire').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:l1]
})

steps[:convert] = Step.where(name: "N20NoaaFireConvert").first_or_create({
  command: "vaf_awips_reformat.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'fire').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:fire]
})

steps[:ldm] = Step.where(name: "N20NoaaFireLDM").first_or_create({
  command: "pqinsert.rb -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:convert]
})


#noaa21
steps = {}
steps[:l1] = Step.where(name: "Noaa21ViirsSdrJob").first

steps[:fire] = Step.where(name: "N21NoaaFire").first_or_create({
  command: "noaa_viirs_fire.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'fire').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:l1]
})

steps[:convert] = Step.where(name: "N21NoaaFireConvert").first_or_create({
  command: "vaf_awips_reformat.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'fire').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:fire]
})

steps[:ldm] = Step.where(name: "N21NoaaFireLDM").first_or_create({
  command: "pqinsert.rb -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:convert]
})



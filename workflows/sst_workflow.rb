
#metop-c
steps = {}
steps[:l1] = Step.where(name: "MetopC_L1").first

steps[:acspo] = Step.where(name: "MetopC_ACSPO_L2").first_or_create({
  command: "acspo_l2.rb -m metop-c -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'acspo_level2').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:l1]
})
steps[:scmi] = Step.where(name: "MetopC_ACSPO_L2_SCMI").first_or_create({
  command: "awips_scmi.rb -m acspo -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:acspo]
})

steps[:ldm] = Step.where(name: "MetopC_ACSPO_L2_SCMI_Ldminsert").first_or_create({
  command: "pqinsert.rb -p ARH_AII_{{job.facility_name.upcase}}_ -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:scmi]
})


#metop-b
steps = {}
steps[:l1] = Step.where(name: "MetopBL1").first

steps[:acspo] = Step.where(name: "MetopB_ACSPO_L2").first_or_create({
  command: "acspo_l2.rb -m metop-c -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'acspo_level2').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:l1]
})
steps[:scmi] = Step.where(name: "MetopB_ACSPO_L2_SCMI").first_or_create({
  command: "awips_scmi.rb -m acspo -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:acspo]
})

steps[:ldm] = Step.where(name: "MetopB_ACSPO_L2_SCMI_Ldminsert").first_or_create({
  command: "pqinsert.rb -p ARH_AII_{{job.facility_name.upcase}}_ -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:scmi]
})


#snpp
steps = {}
steps[:acspo] = Step.where(name: "SSTJob").first

steps[:scmi] = Step.where(name: "SNPP_ACSPO_L2_SCMI").first_or_create({
  command: "awips_scmi.rb -m acspo -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:acspo]
})

steps[:ldm] = Step.where(name: "SNPP_ACSPO_L2_SCMI_Ldminsert").first_or_create({
  command: "pqinsert.rb -p ARH_AII_{{job.facility_name.upcase}}_ -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:scmi]
})



#noaa20
steps = {}
steps[:l1] = Step.where(name: "Noaa20ViirsSdrJob").first

steps[:acspo] = Step.where(name: "Noaa20_ACSPO_L2").first_or_create({
  command: "acspo_l2.rb -m noaa20 -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'acspo_level2').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:l1]
})
steps[:scmi] = Step.where(name: "Noaa20_ACSPO_L2_SCMI").first_or_create({
  command: "awips_scmi.rb -m acspo -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:acspo]
})

steps[:ldm] = Step.where(name: "Noaa20_ACSPO_L2_SCMI_Ldminsert").first_or_create({
  command: "pqinsert.rb -p ARH_AII_{{job.facility_name.upcase}}_ -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'viirs').first_or_create,
  parent: steps[:scmi]
})




#Noaa19
steps = {}
steps[:l1] = Step.where(name: "Noaa19L1").first

steps[:acspo] = Step.where(name: "Noaa19_ACSPO_L2").first_or_create({
  command: "acspo_l2.rb -m n19 -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'acspo_level2').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:l1]
})
steps[:scmi] = Step.where(name: "Noaa19_ACSPO_L2_SCMI").first_or_create({
  command: "awips_scmi.rb -m acspo -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:acspo]
})

steps[:ldm] = Step.where(name: "Noaa19_ACSPO_L2_SCMI_Ldminsert").first_or_create({
  command: "pqinsert.rb -p ARH_AII_{{job.facility_name.upcase}}_ -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:scmi]
})


#Noaa18
steps = {}
steps[:l1] = Step.where(name: "Noaa18L1").first

steps[:acspo] = Step.where(name: "Noaa18_ACSPO_L2").first_or_create({
  command: "acspo_l2.rb -m n18 -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'acspo_level2').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:l1]
})
steps[:scmi] = Step.where(name: "Noaa18_ACSPO_L2_SCMI").first_or_create({
  command: "awips_scmi.rb -m acspo -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:acspo]
})

steps[:ldm] = Step.where(name: "Noaa18_ACSPO_L2_SCMI_Ldminsert").first_or_create({
  command: "pqinsert.rb -p ARH_AII_{{job.facility_name.upcase}}_ -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:scmi]
})

#Terra
steps = {}
steps[:acspo] = Step.where(name: "TerraACSPOL2").first
steps[:scmi] = Step.where(name: "Terra_ACSPO_L2_SCMI").first_or_create({
  command: "awips_scmi.rb -m acspo -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'polar2grid',
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'modis').first_or_create,
  parent: steps[:acspo]
})

steps[:ldm] = Step.where(name: "Terra_ACSPO_L2_SCMI_Ldminsert").first_or_create({
  command: "pqinsert.rb -p ARH_AII_{{job.facility_name.upcase}}_ -t . {{job.input_path}}",
  queue: 'ldm',
  producer: false,
  processing_level: ProcessingLevel.where(name: 'sst_scmi').first_or_create,
  sensor: Sensor.where(name: 'modis').first_or_create,
  parent: steps[:scmi]
})



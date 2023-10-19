
#metop-c
steps = {}
steps[:l1] = Step.where(name: "MetopC_L1").first

steps[:acspo] = Step.where(name: "MetopC_ACSPO_L2").first_or_create({
  command: "nucaps_l2.rb -m metop-c -t {{workspace}} {{job.input_path}} {{job.output_path}}",
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
  parent: steps[:acspo]
})


steps[:heap_ldm] = Step.where(name: 'MetopCNucapsLdmInject').first_or_create({
  command: 'pqinsert.rb -t . {{job.input_path}}',
  queue: 'ldm',
  producer: false,
  parent: steps[:heap_covert],
  enabled: true
})

#metop-b
steps = {}
steps[:l1] = Step.where(name: "MetopBL1").first

steps[:acspo] = Step.where(name: "MetopB_ACSPO_L2").first_or_create({
  command: "nucaps_l2.rb -m metop-c -t {{workspace}} {{job.input_path}} {{job.output_path}}",
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
  parent: steps[:acspo]
})

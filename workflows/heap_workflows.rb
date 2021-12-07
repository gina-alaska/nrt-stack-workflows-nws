
#metop-c
steps = {}
steps[:l1] = Step.where(name: "MetopC_L1").first

steps[:heap] = Step.where(name: "MetopCNucaps").first_or_create({
  command: "nucaps_l2.rb -m metop-c -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'nucaps_level2').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:l1]
})
steps[:heap_covert] = Step.where(name: "MetopCNucapsConvert").first_or_create({
  command: "heap_awips_reformat.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'NucapsAwips').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:heap]
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

steps[:heap] = Step.where(name: "MetopBNucaps").first_or_create({
  command: "nucaps_l2.rb -m metop-c -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'nucaps_level2').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:l1]
})
steps[:heap_covert] = Step.where(name: "MetopBNucapsConvert").first_or_create({
  command: "heap_awips_reformat.rb -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  queue: 'cspp_extras',
  processing_level: ProcessingLevel.where(name: 'NucapsAwips').first_or_create,
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  parent: steps[:heap]
})

steps[:heap_ldm] = Step.where(name: 'MetopBNucapsLdmInject').first_or_create({
  command: 'pqinsert.rb -t . {{job.input_path}}',
  queue: 'ldm',
  producer: false,
  parent: steps[:heap_covert],
  enabled: true
})

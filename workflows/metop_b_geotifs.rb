#-----------------------                GEOTIFF
steps = {}
steps[:l1] = Step.where(name: "MetopBL1").first

steps[:geotiff_l1] = Step.where(name: "MetopBGeoTiff_l1").first_or_create(
  processing_level: ProcessingLevel.where(name: 'geotiff_l1').first_or_create,
  queue: 'polar2grid',
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  command: "p2g_geotif.rb -p 2 -m avhrr -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  parent: steps[:l1])
steps[:geotiff_l2] = Step.where(name: "MetopBGeoTiff_l2").first_or_create(
  processing_level: ProcessingLevel.where(name: 'geotiff_l2').first_or_create,
  queue: 'geotiff',
  sensor: Sensor.where(name: 'avhrr').first_or_create,
  command: "feeder_geotif.rb -m metop-b -t {{workspace}} {{job.input_path}} {{job.output_path}}",
  parent: steps[:geotiff_l1])


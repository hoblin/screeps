var structureSpawn = require('structure.spawn');

var jobQuerry = [
  {
    task: 'harvest',
    workers: 2,
    repeat: 1
  },
  {
    task: 'upgradeController',
    workers: 2,
    repeat: 1,
    customDone: true
  },
  {
    task: 'build',
    structure: 'Extension',
    at: 'Spawn',
    workers: 1,
    repeat: 5
  }
]

module.exports.loop = function () {
  structureSpawn.run(jobQuerry);
}

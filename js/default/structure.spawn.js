var lib = require('lib');
var roleHarvester = require('role.harvester');
var roleUpdater = require('role.updater');
var roleBuilder = require('role.builder');

var structureSpawn = {
  spawn:  Game.spawns.Spawn1,
  querry: Game.spawns.Spawn1.memory.querry,
  getTaskIndex: function () {
    for (var i in this.querry) {
      var task = this.querry[i];
      if (task.done) {lib.log('task '+task.task+' done'); continue};
      if (task.inProgress) {lib.log('task '+task.task+' inProgress');break};
      if (task.inProgress === undefined ) {
        lib.log('task '+task.task+' starts')
        task.inProgress = true;
        return i
      };
      return false
    };
  },
  setCreepKind: function (creep) {
    var functions = [];
    for(var i in creep.body) {
      functions.push(creep.body[i].type)
    }
    var serializedBody = functions.sort();
    if (lib.isSameArray(serializedBody, ['carry','move','work'])) { creep.memory.kind = 'worker' }
    else { lib.log('Undefined creeper kind', serializedBody)}
  },
  getWorkers: function (filter) {
    var creeps = [];
    for (var i in Game.creeps) {
      var creep = Game.creeps[i];
      if(creep.memory.kind === undefined){ this.setCreepKind(creep)}
      if ((filter === undefined) || (creep.memory.process === filter)) { creeps.push(creep) };
    };
    return creeps;
  },
  spawnCreep: function (kind, process) {
    var body;
    switch(kind){
      case 'worker':
      body = [WORK, MOVE, CARRY];
      break
    }
    var name = 'worker' + this.getWorkers().length;
    if (this.spawn.canCreateCreep(body, name) === OK) {this.spawn.createCreep(body, name, {process: process})};
  },
  assignTask: function (taskObj, workersNeeded) {
    var freeWorkers = this.getWorkers('free');
    for(var i = 0; i < workersNeeded; i++) {
      creep = freeWorkers[i];
      if (creep !== undefined) { creep.memory.process = taskObj.task }
    }
  },
  doTheJob: function () {
    var creeps = this.getWorkers();
    for(var i in creeps) {
      var creep = creeps[i];
      switch(creep.memory.process){
        case 'harvest':
        roleHarvester.run(creep);
        break
        case 'upgradeController':
        roleUpdater.run(creep);
        break
        case 'build':
        roleBuilder.run(creep);
        break
        default:
        roleHarvester.run(creep);
      }
    }
  },
  run: function(querry) {
    if(this.querry === undefined) { this.spawn.memory.querry = querry };
    var taskIndex = this.getTaskIndex();
    if (taskIndex) { this.spawn.memory.taskIndex = taskIndex };
    var currentTask = this.querry[this.spawn.memory.taskIndex];
    var workersNeeded = currentTask.workers - this.getWorkers(currentTask.task).length;
    // lib.log(currentTask.task)
    // lib.log(workersNeeded)
    if (workersNeeded > 0) {
      if (this.getWorkers('free').length > 0) {
        this.assignTask(currentTask.task, workersNeeded);
      } else {
        this.spawnCreep('worker', currentTask.task);
      };
    } else if ((!currentTask.customDone) && (workersNeeded === 0)) { currentTask.done = true };
    // Custome done processing
    if (currentTask.customDone) {
      switch(currentTask.task){
        case 'upgradeController':
        if (this.spawn.room.controller.level === 2) { currentTask.done = true };
        break;
      }
    };

    // Process creepers
    this.doTheJob();
  }
};

module.exports = structureSpawn;

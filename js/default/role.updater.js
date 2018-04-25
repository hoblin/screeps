var roleUpdater = {
  run: function(creep) {
    if(creep.memory.mode == undefined){ creep.memory.mode = true }

    if(creep.memory.mode){
      var sources = creep.room.find(FIND_SOURCES);
      if(creep.harvest(sources[0]) == ERR_NOT_IN_RANGE) {
        creep.moveTo(sources[0]);
      }
      if(creep.carry.energy == creep.carryCapacity){creep.memory.mode = false }
    } else {
      if(creep.upgradeController(creep.room.controller) == ERR_NOT_IN_RANGE) {
        creep.moveTo(creep.room.controller);
      }
      if(creep.carry.energy == 0){creep.memory.mode = true }
    }
  }
};

module.exports = roleUpdater;

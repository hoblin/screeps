module.exports = {
  debug: true,
  isSameArray: function (array1, array2) {
    return (array1.length == array2.length) && array1.every(function(element, index) {
      return element === array2[index]; 
    });
  },
  log: function (args) {
    if(this.debug) { console.log(args) }
  }
}

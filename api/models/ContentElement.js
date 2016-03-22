/**
 * ContentElement.js
 *
 * @description :: TODO: You might write a short summary of how this model works and what it represents here.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {

    name:{
      type: "String",
      required: true
    },

    ctype:{
      model: "ContentType",
      required: true
    },

    content:{
      type: "String",
      required: true
    },

    style:{
      type: "String",
      required: true
    },

    parent:{
      type: "ContentElement",
      defaultsTo: null //It's first in the hierarchy...
    },

    index:{
      type: "int",
      required: true,
      defaultsTo: 0
    },

    myPages:{
      collection: "Page",
      via: "elements"
    }

  }
};


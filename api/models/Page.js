/**
 * Page.js
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

    url:{
      type: "String",
      required: true,
      unique: true
    },

    published:{
      type: "boolean",
      required: true,
      defaultsTo: true
    },

    elements:{
      collection: "ContentElement",
      via: "myPages",
      dominant: true
    }

  }
};


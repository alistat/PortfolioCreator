/**
 * ContentType.js
 *
 * @description :: ContentType Model, indicate the type of the contentElement.
 * @docs        :: http://sailsjs.org/documentation/concepts/models-and-orm/models
 */

module.exports = {

  attributes: {

    name:{
      type: "String",
      required: true,
      unique: true
    },

    renderFunction: {
      type: "String"
    },

    description:{
      type: "String",
      defaultsTo: 'No Description added.'
    }

  }
};


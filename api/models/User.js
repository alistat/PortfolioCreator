/**
 * User.js
 *
 * @description :: Simple User Model
 *
 */

module.exports = {

  attributes: {

    username:{
      type: "string",
      required: true,
      unique: true
    },

    encryptedPassword:{
      type: "string",
      required: true,
      columnName: "password"
    },

    email:{
      type: "email",
      required: true,
      unique: true,
      columnName: "email_address"
    }

  }
};


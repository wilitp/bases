
// 1) Especificar en la colección users las siguientes reglas de validación: El campo name (requerido) debe ser un string con un máximo de 30 caracteres, email (requerido) debe ser un string que matchee con la expresión regular: "^(.*)@(.*)\\.(.{2,4})$" , password (requerido) debe ser un string con al menos 50 caracteres.


use("mflix")
db.runCommand({
  collMod: "users",
  validator: {
    $jsonSchema: {
      required: ["email", "name", "password"],
      properties: {
        name: {
          bsonType: "string",
          maxLength: 30,
        },
        email: {
          bsonType: "string",
          pattern: "^(.*)@(.*)\\.(.{2,4})$",
          minLength: 50,
        },
        password: {
          bsonType: "string",

        }


      }
    }
  }
})
// 2) Obtener metadata de la colección users que garantice que las reglas de validación fueron correctamente aplicadas.

use("mflix")
db.getCollectionInfos({ name: "users" });

// 3) Especificar en la colección theaters las siguientes reglas de validación: El campo theaterId (requerido) debe ser un int y location (requerido) debe ser un object con:
// a. un campo address (requerido) que sea un object con campos street1, city, state y zipcode todos de tipo string y requeridos
// b. un campo geo (no requerido) que sea un object con un campo type, con valores posibles “Point” o null y coordinates que debe ser una lista de 2 doubles
// Por último, estas reglas de validación no deben prohibir la inserción o actualización de documentos que no las cumplan sino que solamente deben advertir.


use("mflix")
db.runCommand({
  collMod: "theaters",
  validator: {
    $jsonSchema: {
      required: ["theaterId", "location"],
      properties: {
        theaterId: {
          bsonType: "int"
        },
        location: {
          bsonType: "object",
          required: ["address"],
          properties: {
            address: {
              bsonType: "object",
              required: ["street1", "city", "state", "zipcode"],
              properties: {
                street1: {
                  bsonType: "string"
                },
                city: {
                  bsonType: "string"
                },
                state: {
                  bsonType: "string"
                },
                zipcode: {
                  bsonType: "string"
                }
              }
            },
            geo: {
              bsonType: "object",
              required: ["type"],
              properties: {
                type: {
                  enum: ["Point", null]
                },
                coordinates: {
                  bsonType: "array",
                  items: {
                    type: "number"
                  },
                  minLength: 2,
                  maxLength: 2
                }

              }
            }
          }
        }
      }
    }
  }
})
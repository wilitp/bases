// 1) Buscar las ventas realizadas en "London", "Austin" o "San Diego"; a un customer con edad mayor-igual a 18 años que tengan productos que hayan salido al menos 1000 y estén etiquetados (tags) como de tipo "school" o "kids" (pueden tener más etiquetas).
// Mostrar el id de la venta con el nombre "sale", la fecha (“saleDate"), el storeLocation, y el "email del cliente. No mostrar resultados anidados. 

// ACLARACION: al preguntar durante el parcial, se dijo que esta condicion sobre los items de venta deben cumplirse AMBAS para al menos UN ITEM. No vale una para un item y otra para otro.

use("supplies");
db.sales.find(
  {
    storeLocation: {
      $in: ["London", "Austin", "San Diego"]
    },
    "customer.age": {
      $gte: 18
    },
    items: {
      $elemMatch: {
        price: {
          $gte: 1000
        },
        tags: { $in: ["school", "kids"] }
      }
    }
  },
  {
    sale: "_id",
    saleDate: 1,
    storeLocation: 1,
    customerEmail: "$customer.email"
  }
);

// 2) Buscar las ventas de las tiendas localizadas en Seattle, donde el método de compra sea ‘In store’ o ‘Phone’ y se hayan realizado entre 1 de febrero de 2014 y 31 de enero de 2015 (ambas fechas inclusive). Listar el email y la satisfacción del cliente, y el monto total facturado, donde el monto de cada item se calcula como 'price * quantity'. Mostrar el resultado ordenados por satisfacción (descendente), frente a empate de satisfacción ordenar por email (alfabético). 

use("supplies")
db.sales.aggregate(
  [
    {
      $match: {
        storeLocation: 'Seattle',
        purchaseMethod: {
          $in: ['Phone', 'In store']
        },
        saleDate: {
          $gte: ISODate(
            '2014-02-01T03:00:00.000Z'
          ),
          $lt: ISODate('2015-02-01T03:00:00.000Z')
        }
      }
    },
    {
      $unwind: {
        path: '$items',
        includeArrayIndex: 'itemIndex',
        preserveNullAndEmptyArrays: false
      }
    },
    {
      $addFields: {
        itemAmount: {
          $multiply: [
            '$items.quantity',
            '$items.price'
          ]
        },
        email: '$customer.email',
        satisfaction: '$customer.satisfaction'
      }
    },
    {
      $group: {
        _id: '$_id',
        amount: { $sum: '$itemAmount' },
        email: { $first: '$email' },
        satisfaction: { $first: '$satisfaction' }
      }
    },
    {
      $project: {
        _id: 0,
      }

    },
    {
      $sort: {
        satisfaction: -1,
        email: 1,
      }
    }
  ],
);

// 3) Crear la vista salesInvoiced que calcula el monto mínimo, monto máximo, monto total y monto promedio facturado por año y mes.  Mostrar el resultado en orden cronológico. No se debe mostrar campos anidados en el resultado.

// ACLARACION: durante el parcial se dijo que la "unidad" a tener en cuenta a la hora de calcular estos montos(promedio, maximo, minimo, total) es el monto POR ITEM(qty * price).

const salesInvoicedAgg = [
  {
    $unwind: {
      path: '$items',
      includeArrayIndex: 'itemIndex',
      preserveNullAndEmptyArrays: false
    }
  },
  {
    $addFields: {
      amount: {
        $multiply: [
          '$items.quantity',
          '$items.price'
        ]
      },
      date: '$saleDate'
    }
  },
  {
    $group: {
      _id: {
        $dateTrunc: {
          date: '$date',
          unit: 'month'
        }
      },
      avgAmount: { $avg: '$amount' },
      minAmount: { $min: '$amount' },
      maxAmount: { $max: '$amount' },
      totalAmount: { $sum: '$amount' }
    }
  },
  { $sort: { _id: 1 } },
  {
    $addFields: {
      month: { $month: '$_id' },
      year: { $year: '$_id' }
    }
  },
  { $project: { _id: 0 } }
]

use("supplies")
db.salesInvoiced.drop()
db.createView("salesInvoiced", "sales", salesInvoicedAgg);

// 4) Mostrar el storeLocation, la venta promedio de ese local, el objetivo a cumplir de ventas (dentro de la colección storeObjectives) y la diferencia entre el promedio y el objetivo de todos los locales.

use("supplies")
db.sales.aggregate(
  [
    {
      $unwind: {
        path: '$items',
        includeArrayIndex: 'itemIndex',
        preserveNullAndEmptyArrays: false
      }
    },
    {
      $group: {
        _id: '$storeLocation',
        amount: {
          $avg: {
            $multiply: [
              '$items.quantity',
              '$items.price'
            ]
          }
        },
        date: { $first: '$saleDate' }
      }
    },
    {
      $lookup: {
        from: 'storeObjectives',
        localField: '_id',
        foreignField: '_id',
        as: 'objective'
      }
    },
    {
      $unwind: {
        path: '$objective',
        includeArrayIndex: 'objectiveIndex',
        preserveNullAndEmptyArrays: true
      }
    },
    {
      $project: {
        avgAmount: '$amount',
        objective: '$objective.objective',
        differenceFromObjective: {
          $subtract: [
            '$amount',
            '$objective.objective'
          ]
        }
      }
    }
  ],
);

// 5) Especificar reglas de validación en la colección sales utilizando JSON Schema. 
// a. Las reglas se deben aplicar sobre los campos: saleDate, storeLocation, purchaseMethod, y  customer ( y todos sus campos anidados ). Inferir los tipos y otras restricciones que considere adecuados para especificar las reglas a partir de los documentos de la colección. 
// b. Para testear las reglas de validación crear un caso de falla en la regla de validación y un caso de éxito (Indicar si es caso de falla o éxito)

// a. Reglas de validacion

const salesSchema = {
  $jsonSchema: {
    required: [
      "saleDate",
      "storeLocation", 
      "purchaseMethod", 
    ],
    properties: {
      couponUsed: {
        bsonType: "bool"
      },
      saleDate: {
        bsonType: "date"
      },
      storeLocation: {
        enum: ["Denver", "Seattle", "Austin", "London", "New York", "San Diego"]
      },
      purchaseMethod: {
        enum: ["In store", "Online", "Phone"]
      },
      customer: {
        bsonType: "object",
        required: [
          "age", 
          "email", 
          "gender", 
          "satisfaction"
        ],
        properties: {
          age: {
            bsonType: "int",
            minimum: 0,
          },
          satisfaction: {
            bsonType: "int",
            minimum: 1,
            maximum: 5
          },
          gender: {
            enum: ["M", "F"]
          },
          email: {
            bsonType: "string",
            pattern: "^(.*)@(.*)\\.(.{2,4})$"
          }
        }
      },
    }
  }
}

// Esta query da vacio, por lo que al menos el esquema es valido para los documentos existentes
use("supplies")
db.sales.find({ $nor: [salesSchema] })

use("supplies")
db.runCommand({
  collMod: "sales",
  validator: salesSchema
})

// b. 


// Caso de éxito: una compra el día de hoy
use("supplies")
db.sales.insertOne({
  saleDate: new Date(),
  storeLocation: "Denver",
  couponUsed: false,
  customer: {
    email: "example@example.com",
    age: 22,
    gender: "M",
    satisfaction: 2
  },
  purchaseMethod: "Phone",
  items: [
    {
      name: "books",
      quantity: 1,
      price: 50
    }
  ]

})

// Caso de falla: insertar un documento con customer.age negativa
use("supplies")
db.sales.insertOne({
  saleDate: new Date(),
  storeLocation: "Denver",
  couponUsed: false,
  customer: {
    email: "example@example.com",
    age: -2,
    gender: "M",
    satisfaction: 2
  },
  purchaseMethod: "Phone",
  items: [
    {
      name: "books",
      quantity: 1,
      price: 50
    }
  ]
})
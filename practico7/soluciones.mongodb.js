/* global use, db */
// MongoDB Playground
// To disable this template go to Settings | MongoDB | Use Default Template For Playground.
// Make sure you are connected to enable completions and to be able to run a playground.
// Use Ctrl+Space inside a snippet or a string literal to trigger completions.
// The result of the last command run in a playground is shown on the results panel.
// By default the first 20 documents will be returned with a cursor.
// Use 'console.log()' to print to the debug output.
// For more documentation on playgrounds please refer to
// https://www.mongodb.com/docs/mongodb-vscode/playgrounds/


// 2) Listar el título, año, actores (cast), directores y rating de las 10 películas con mayor rating (“imdb.rating”) de la década del 90. ¿Cuál es el valor del rating de la película que tiene mayor rating? (Hint: Chequear que el valor de “imdb.rating” sea de tipo “double”).

use('mflix');
db.movies.find({
    "imdb.rating": {"$type": "double"},
    year: {"$gte": 1990, "$lte": 1999}
},
{
    "title": 1,
    "directors": 1,
    "cast": 1,
    "year": 1,
    "rating": "$imdb.rating"
}).sort({"imdb.rating": -1}).limit(10);

// 3) Listar el nombre, email, texto y fecha de los comentarios que la película con id (movie_id) ObjectId("573a1399f29313caabcee886") recibió entre los años 2014 y 2016 inclusive. Listar ordenados por fecha. Escribir una nueva consulta (modificando la anterior) para responder ¿Cuántos comentarios recibió?
movie_id = new ObjectId("573a1399f29313caabcee886")
from = new Date(2014, 0);
to = new Date(new Date(2017, 0) - 1);

use('mflix');
db.comments.find({
    "date": {"$gte": from, "$lte": to},
    "movie_id": movie_id
}, 
{
    "_id": 0,
    text: 1,
    email: 1,
    name: 1,
    date: 1
}).sort({"date": 1});

movie_id = new ObjectId("573a1399f29313caabcee886")
from = new Date(2014, 0);
to = new Date(new Date(2017, 0) - 1);
use('mflix');
db.comments.find({
    "date": {"$gte": from, "$lte": to},
    "movie_id": movie_id
}, 
{
    "_id": 0,
    text: 1,
    email: 1,
    name: 1,
    date: 1
}).count();

// 4) Listar el nombre, id de la película, texto y fecha de los 3 comentarios más recientes realizados por el usuario con email patricia_good@fakegmail.com. 


use('mflix');
db.comments.find(
    {
        email: "patricia_good@fakegmail.com"
    },
    {
        date: 1,
        name: 1,
        movie_id: 1,
        text: 1,
        "_id": 0
    }
    ).sort({date: -1}).limit(3);

// 5) Listar el título, idiomas (languages), géneros, fecha de lanzamiento (released) y número de votos (“imdb.votes”) de las películas de géneros Drama y Action (la película puede tener otros géneros adicionales), que solo están disponibles en un único idioma y por último tengan un rating (“imdb.rating”) mayor a 9 o bien tengan una duración (runtime) de al menos 180 minutos. Listar ordenados por fecha de lanzamiento y número de votos.

use("mflix");
db.movies.find(
    {
        genres: {
            $elemMatch: {
                $in: ["Drama", "Action"]
            }
        },
        languages: {$size: 1},
        $or: [
            {
                "imdb.rating": {$gt: 9}
            },
            {
                "duration": {$gte: 180}
            },
        ]

    }, 
    {
        title: 1,
        genres: 1,
        year: 1,
        votes: "$imdb.votes"
    }
).sort({year: -1, "imdb.votes": -1});

// 6) Listar el id del teatro (theaterId), estado (“location.address.state”), ciudad (“location.address.city”), y coordenadas (“location.geo.coordinates”) de los teatros que se encuentran en algunos de los estados "CA", "NY", "TX" y el nombre de la ciudades comienza con una ‘F’. Listar ordenados por estado y ciudad.

use("mflix");
db.theaters.find(
    {
        "location.address.state": {
            $in: ["CA", "NY", "TX"],
            $exists: true
        },
        "location.address.city": {
            $regex: "F.*$"
        }
    },
    {
        theaterId: 1,
        state: "$location.address.state",
        city: "$location.address.city",
        coordinates: "$location.geo.coordinates"
    }
).sort({"location.address.state": -1, "location.address.city": -1});

// 7) Actualizar los valores de los campos texto (text) y fecha (date) del comentario cuyo id es ObjectId("5b72236520a3277c015b3b73") a "mi mejor comentario" y fecha actual respectivamente.

use("mflix");
db.comments.updateOne(
    {
    "_id": new ObjectId("5b72236520a3277c015b3b73")
    }, 
    {
        $set: {
            text: "mi mejor comentario",
            date: new Date()
        }
    }
);

// Verificacion
use("mflix");
db.comments.find(
    {
    "_id": new ObjectId("5b72236520a3277c015b3b73")
    }, 
    {
    }
)


// 8) Actualizar el valor de la contraseña del usuario cuyo email es joel.macdonel@fakegmail.com a "some password". La misma consulta debe poder insertar un nuevo usuario en caso que el usuario no exista. Ejecute la consulta dos veces. ¿Qué operación se realiza en cada caso?  (Hint: usar upserts). 

use("mflix");
db.users.updateOne(
    {
        "email": "joel.macdonel@fakegmail.com"
    },
    {
        $set: {
            password: "some password"
        }
    },
    {upsert: true}
)

use("mflix");
db.users.find(
    {
        "email": "joel.macdonel@fakegmail.com"
    }, 
    {
    }
)

// 9) Remover todos los comentarios realizados por el usuario cuyo email es victor_patel@fakegmail.com durante el año 1980.

use("mflix");
db.comments.deleteMany(
    {
        email: "victor_patel@fakegmail.com",
        $expr: {$eq: [{$year: "$date"}, 1980]} 
    }
)

// Verificacion
use("mflix");
db.comments.find(
    {
        email: "victor_patel@fakegmail.com",
        $expr: {$eq: [{$year: "$date"}, 1980]} 
    }
)

// 10) Listar el id del restaurante (restaurant_id) y las calificaciones de los restaurantes donde al menos una de sus calificaciones haya sido realizada entre 2014 y 2015 inclusive, y que tenga una puntuación (score) mayor a 70 y menor o igual a 90.

use("restaurantdb")
db.restaurants.find(
    {
        grades: {
            $elemMatch: {
                date: {
                    $gte: new Date(2014, 0, 0, 0),
                    $lt: new Date(2016, 0, 0, 0)
                },
                score: {
                    $gt: 70,
                    $lte: 90
                }
            }
        }
    },
    {
        _id: 1,
        grades: 1

        // Si quisieras efectivamente conseguir solo los grades que matcheen, proyectar lo siguiente:
        // grades: {
        //     $filter: {
        //         input: "$grades",
        //         as: "grade",
        //         cond: {
        //             $and: [
        //                 {
        //                     $gte: ["$$grade.date", new Date(2014, 0, 0, 0)]
        //                 },
        //                 {
        //                     $lt: ["$$grade.date", new Date(2016, 0, 0, 0)]
        //                 },
        //                 {
        //                     $gt: ["$$grade.score", 70]
        //                 },
        //                 {
        //                     $lte: ["$$grade.score", 90]
        //                 },
        //             ]
        //         }
        //     }
        // }

    }
);

// 11) Agregar dos nuevas calificaciones al restaurante cuyo id es "50018608". A continuación se especifican las calificaciones a agregar en una sola consulta.  

// cambio el id a `new ObjectId("655695ca237a8a55425eabd8")` pq el que dice el enunciado esta incompleto(le faltan caracteres para ser un id valido)

resId = new ObjectId("655695ca237a8a55425eabd8");

newgrades = [{
	"date" : new ISODate("2019-10-10T00:00:00Z"),
	"grade" : "A",
	"score" : 18
},
{
	"date" : new ISODate("2020-02-25T00:00:00Z"),
	"grade" : "A",
	"score" : 21
}];

for (grade of newgrades) {
    use("restaurantdb");
    db.restaurants.updateOne(
        {
            _id: resId
        },
        {
            $push: {
                "grades": grade
            }
        }
    )
}
// 9) Crear una vista con los 5 géneros con mayor cantidad de comentarios, junto con la cantidad de comentarios.

const commentsPerGenreAgg = [
    {
        $lookup: {
            from: "movies",
            as: "movies",
            localField: "movie_id",
            foreignField: "_id",
        },
    },
    {
        $unwind:
        {
            path: "$movies",
            includeArrayIndex: "index",
            preserveNullAndEmptyArrays: false,
        },
    },
    {
        $replaceRoot:
        {
            newRoot: "$movies",
        },
    },
    {
        $unwind:
        {
            path: "$genres",
            includeArrayIndex: "index",
            preserveNullAndEmptyArrays: false,
        },
    },
    {
        $project:
        {
            genres: 1,
        },
    },
    {
        $group: {
            _id: "$genres",
            commentCount: {
                $sum: 1,
            },
        },
    },
    {
        $sort: {
            commentCount: -1
        }
    },
    {
        $limit: 5
    }
]

// db.comments.aggregate(
//     commentsPerGenreAgg
// )

use("mflix")
db.CommentCountPerGenre.drop()
db.createView("CommentCountPerGenre", "comments", commentsPerGenreAgg)

use("mflix")
db.CommentCountPerGenre.find();

// 10. Listar los actores (cast) que trabajaron en 2 o más películas dirigidas por "Jules Bass". Devolver el nombre de estos actores junto con la lista de películas (solo título y año) dirigidas por “Jules Bass” en las que trabajaron. 
// Hint1: addToSet
// Hint2: {'name.2': {$exists: true}} permite filtrar arrays con al menos 2 elementos, entender por qué.
// Hint3: Puede que tu solución no use Hint1 ni Hint2 e igualmente sea correcta

use("mflix");
db.movies.aggregate(
    [
        {
            $unwind: {
                path: '$cast',
                includeArrayIndex: 'actorIndex',
                preserveNullAndEmptyArrays: false
            }
        },
        {
            $unwind: {
                path: '$directors',
                includeArrayIndex: 'directorIndex',
                preserveNullAndEmptyArrays: false
            }
        },
        { $match: { directors: 'Jules Bass' } },
        {
            $group: {
                _id: '$cast',
                movies_ids: { $addToSet: '$_id' },
                movies: {
                    $push:
                    {
                        title: '$title',
                        year: "$year"
                    }
                },
                movie_count: { $sum: 1 }
            }
        },
        { $match: { movie_count: { $gte: 2 } } },
    ]
);

// 11) Listar los usuarios que realizaron comentarios durante el mismo mes de lanzamiento de la película comentada, mostrando Nombre, Email, fecha del comentario, título de la película, fecha de lanzamiento. HINT: usar $lookup con multiple condiciones 

use("mflix")
db.comments.aggregate(
    [
        {
            $lookup: {
                from: 'movies',
                as: 'movies',
                localField: 'movie_id',
                foreignField: '_id',
                let: {
                    comment_month: {
                        year: { $year: '$date' },
                        month: { $month: '$date' }
                    }
                },
                pipeline: [
                    {
                        $match: {
                            $expr: {
                                $eq: [
                                    '$$comment_month',
                                    {
                                        year: { $year: '$released' },
                                        month: { $month: '$released' }
                                    }
                                ]
                            }
                        }
                    }
                ]
            }
        },
        {
            $unwind: {
                path: '$movies',
                includeArrayIndex: 'movieIndex',
                preserveNullAndEmptyArrays: false
            }
        },
        {
            $project: {
                email: 1,
                name: 1,
                date: 1,
                title: '$movie.title',
                released: '$movies.released'
            }
        }
    ]
);

// 12) Listar el id y nombre de los restaurantes junto con su puntuación máxima, mínima y la suma total. Se puede asumir que el restaurant_id es único.

use("restaurantdb")
db.restaurants.aggregate(
    [
        {
            $unwind: {
                path: '$grades',
                includeArrayIndex: 'scoreIndex',
                preserveNullAndEmptyArrays: false
            }
        },
        {
            $group: {
                _id: { id: '$_id', name: '$name' },
                maxScore: { $max: '$grades.score' },
                minScore: { $min: '$grades.score' },
                sumScore: { $sum: '$grades.score' }
            }
        },
        {
            $addFields: {
                name: '$_id.name',
                _id: '$_id.id'
            }
        }
    ],
);

// 13) 
// Actualizar los datos de los restaurantes añadiendo dos campos nuevos. 
// "average_score": con la puntuación promedio
// "grade": con "A" si "average_score" está entre 0 y 13, 
//   con "B" si "average_score" está entre 14 y 27 
//   con "C" si "average_score" es mayor o igual a 28    
// Se debe actualizar con una sola query.
// HINT1. Se puede usar pipeline de agregación con la operación update
// HINT2. El operador $switch o $cond pueden ser de ayuda.


const updateAgg = [
    {
        $addFields: {
            average_score: {
                $avg: "$grades.score"
            },
        }
    },
    {
        $addFields: {
            grade: {
                $switch: {
                    branches: [
                        { case: { $and: [{ $lt: ["$average_score", 14] }, { $gte: ["$average_score", 0] }] }, then: "A" },
                        { case: { $and: [{ $lt: ["$average_score", 28] }, { $gte: ["$average_score", 14] }] }, then: "B" },
                        { case: { $gte: ["$average_score", 28] }, then: "C" },

                    ],
                    default: "C"

                }
            }
        }
    },
]

use("restaurantdb")
db.restaurants.find().limit(5)
db.restaurants.updateMany({}, updateAgg);

const express = require('express')
var bodyParser = require('body-parser')
var cors = require('cors')

var app = express()
 
app.use(cors())
app.use(bodyParser.json({ type: "*/*" } ))


// app.use(bodyParser.urlencoded({ extended: true }));

const port = 3000
var jsonParser = bodyParser.json()

var cars = [];

app.get('/cars', (req, res) => {
    res.json(cars)
})
app.post('/cars', (req, res) => {
    console.log(req.body);
    cars.push(req.body);
    res.status(200)
})

app.listen(port, () => {
    console.log(`LD47 listening at http://localhost:${port}`)
})

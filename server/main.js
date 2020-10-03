const express = require('express')
var bodyParser = require('body-parser')
var cors = require('cors')

var app = express()
 
app.use(cors())
app.use(bodyParser.raw({ type: "*/*" } ))


// app.use(bodyParser.urlencoded({ extended: true }));

const port = 3000

var races = [];
var raceData = [];

app.get('/races', (req, res) => {
    res.send(races)
})
app.post('/cars', (req, res) => {
    console.log(req.body);

    var id = raceData.length;
    races.push({ "id": id});
    raceData[id] = req.body;

    res.status(200).end();
})
app.get("/race/:raceId", (req, res) => {
    res.send(raceData[req.params.raceId]);
});

app.listen(port, () => {
    console.log(`LD47 listening at http://localhost:${port}`)
})

var express = require("express");
var app = express();
var MongoClient = require("mongodb");
var settings = require("./hierarchy_setting.js");
var bodyParser = require('body-parser');
var ObjectID = require('mongodb').ObjectID;
var BinData = require('mongodb').BinData;
var fs = require("fs");
var mongoose = require('mongoose');
var Schema = mongoose.Schema;
var mkdirp = require('mkdirp');
var path = require('path');
app.use(bodyParser());


/*
MongoClient.connect("mongodb://localhost/"+settings.db, function(err,db){
if(err){ return console.log(err); }
console.log("connected to db")
});
*/

// with match request to the root
app.get('/get_image/:id', function (req, res) {
  console.log("req id is "+req.params.id);
  var image_file = __dirname+'/user_images/'+req.params.id+".jpg";
  console.log(image_file);
	var type = 'image/png';
	if( fs.existsSync( image_file ) ){
		var imgData = fs.readFileSync( image_file, 'binary' );
		res.writeHead(200, {'Content-Type': type } );
		res.end( imgData, 'binary' );
	}else{
    res.writeHead(404, {'Content-Type': "text/plain" } );
		res.end("404");
  }
})

app.get('/create_user', function (req, res) {
  ip = req.headers['x-forwarded-for'] ||
  req.connection.remoteAddress ||
  req.socket.remoteAddress ||
  req.connection.socket.remoteAddress;

  var id = Math.random() * 10000000000000000000;
  if (req.query.id) {
    id = req.query.id;
  }

  MongoClient.connect("mongodb://localhost/"+settings.db, function(err, db) {
    if (err) { return console.dir(err); };

    db.collection("users", function(err, collection) {
      if(err){ return console.dir(err); }
      var docs = [
        {
          name: "default",
          create_ip: ip,
          id: id,
          create_date: new Date()
        }
      ];

      collection.insert(docs, function(err, result){
        if(err){ return console.dir(err); }
        collection.find( {id: id} ).toArray(function(err, items){
          if(err){ return console.dir(err); }

          var ress = [];
          for (i=0; i<items.length; i++){

            ress.push(items[i]);
          }

          console.log("same id users : " + items.length);
          if(items.length == 1 || true){
            var resJSON = JSON.stringify(ress);
            res.send(resJSON)
          }else{
            return console.log("exist same id");
          }

          db.close();
        });
      });
    });
  });
});

app.get('/id_get', function (req, res) {

  console.log(req.query); // for logging
  var id = 0;
  if (req.query.id) {
    id = req.query.id;
  }

  MongoClient.connect("mongodb://localhost/"+settings.db, function(err, db) {
    if (err) { return console.dir(err); };

    db.collection("hierarchy", function(err, collection) {
      var find_params = {
        id: id,
        deleted: false
      }
      collection.find(find_params).toArray(function (err, items){
        console.dir(items);

        var ress = [];

        for (i=0; i<items.length; i++){
          var push_params = {
            neme: items[i].name,
            id: items[i].id,
            contents: items[i].contents,
            my_hierarchy: items[i].my_hierarchy,
            parent_hierarchy: items[i].parent_hierarchy,
            image_num: items[i].image_num,
            red: items[i].red,
            green: items[i].green,
            blue: items[i].blue,
            create_date: items[i].create_date
          }
          ress.push(push_params);
        }
        db.collection("users", function(err, collection) {
          collection.find({_id: ObjectID(id)}).toArray(function (err, items){
            var push_params = {
              name: items[0].name,
              image_num: items[0].image_num,
              red: items[0].red,
              green: items[0].green,
              blue: items[0].blue
            }
            ress.push(push_params);
            console.dir(items);

            var resJSON = JSON.stringify(ress);
            res.send(resJSON)

            db.close();
          });
        });
      });

    });

  });


})

app.get('/random.text', function (req, res) {
  res.send('random.text')
})

app.get("/path_get", function(req, res){
  //res.send('about')

  console.log(req.query); // for logging
  var ph = "";
  // パラメタが空でなければ画面に表示
  if (req.query.parents_hierarchy) {
    ph = req.query.parents_hierarchy;
  }

  MongoClient.connect("mongodb://localhost/"+settings.db, function(err, db) {
    if (err) { return console.dir(err); };

    db.collection("hierarchy", function(err, collection) {
      var id = Math.random() * 10000000000;
      var find_params = {
        parent_hierarchy: ph,
        deleted: false
      }

      if(ph != "/"){
        collection.find(find_params).toArray(function (err, items){
          console.log(ph);
          console.dir(items);

          var ress = [];
          for (i=0; i<items.length; i++){
            var push_params = {
              _id: items[i]._id,
              name: items[i].name,
              id: items[i].id,
              contents: items[i].contents,
              my_hierarchy: items[i].my_hierarchy,
              parent_hierarchy: items[i].parent_hierarchy,
              image_num: items[i].image_num,
              red: items[i].red,
              green: items[i].green,
              blue: items[i].blue,
              create_date: items[i].create_date
            }
            ress.push(push_params);
          }

          var resJSON = JSON.stringify(ress);
          res.send(resJSON)

          db.close();
        });
      }else{
        collection.find(find_params).sort({"update_date":1}).toArray(function (err, items){
          console.log(ph);
          console.dir(items);

          var ress = [];
          for (i=0; i<items.length; i++){
            ress.push(items[i]);
          }

          var resJSON = JSON.stringify(ress);
          res.send(resJSON)

          db.close();
        });
      }

    });
  });

})

var current_edit_id = ObjectID();

app.post("/user_update", function (req, res){
  ip = req.headers['x-forwarded-for'] ||
  req.connection.remoteAddress ||
  req.socket.remoteAddress ||
  req.connection.socket.remoteAddress;

  console.dir(req.body);
  MongoClient.connect("mongodb://localhost/"+settings.db, function(err, db) {
    if (err) { return console.dir(err); }
    db.collection("users", function(err, collection) {

      var docs = {
        name: req.body.name,
        image_num: req.body.image_num,
        red: req.body.red,
        green: req.body.green,
        blue: req.body.blue,
        update_ip: ip,
        update_date: new Date()
      }

      //console.log(req.body.userid);

      var id = ObjectID.createFromHexString(req.body.userid)
      //console.log(id)

      collection.update({ "_id" : id }, { $set: docs }, function(err, result) {
        if(err){ res.send("{success: false}") };
        res.send( "{success: true}" );
        //current_edit_id = id

        db.close();
      });

    });
  });

});

app.post("/image_upload", function (req, res){
  ip = req.headers['x-forwarded-for'] ||
  req.connection.remoteAddress ||
  req.socket.remoteAddress ||
  req.connection.socket.remoteAddress;

  /*
  var imgPath = _filedir + '/user_images';// img path
  mongoose.connect('localhost', settings.db);// connect to mongo
  var schema = new Schema({
  img: { data: Buffer, contentType: String }
});// example schema
var A = mongoose.model('A', schema);// our model

mongoose.connection.on('open', function () {
console.error('mongo is open');

// store an img in binary in mongo
var a = new A;
a.img.data = fs.readFileSync(imgPath+current_edit_id+".png");
a.img.contentType = 'image/png';
a.save(function (err, a) {
if (err) throw err;

console.error('saved img to mongo');

});

});
*/


  mkdirp(__dirname+'/user_images/'+current_edit_id, function (err) {
    if (err) {
      console.error(err)
    } else {
      //console.log('success')
      //console.dir(MongoClient.Binary(Buffer(req.body)));
      //console.log(Buffer(req.body));

      MongoClient.connect("mongodb://localhost/"+settings.db, function(err, db) {
        db.collection("users", function(err, collection) {
          if(req.body){
            console.log("image saving");

            /*
            // tmp_pathにとりあえず保存して
            var tmp_path = req.files.nameOfFileTag.path,
            target_path = './user_images';

            // それをtarget_pathへコピー
            fs.rename(tmp_path, target_path, function(err) {
              // そのあとtmp_pathを削除
              fs.unlink(tmp_path, function() {
                res.redirect('/myUploader');
              });
            });
            */

            console.log(req.body);

            fs.writeFile(__dirname+'/user_images/'+current_edit_id+'/image.png', req.body, "binary", function (err) {
              if (err) throw err;
              console.log('It\'s saved!');
            });

            var data = "",
            base64Data,
            binaryData;

            data = String(req.body);
            println(data);

            base64Data  =   data.replace(/^data:image\/png;base64,/, "");
            base64Data  +=  base64Data.replace('+', ' ');
            binaryData  =   new Buffer(base64Data, 'base64').toString('binary');

            fs.writeFile("out.png", binaryData, "binary", function (err) {
              console.log(err); // writes out file without error, but it's not a valid image
            });

          /*
          collection.update({ "_id" : current_edit_id }, { $set: {image: MongoClient.Binary(Buffer(req.body))} }, function(err, result) {
          if(err){ res.send("{success: false}") };

          res.send( "{success: true}" );
          current_edit_id = ObjectID();
          db.close();

          console.log("image saved");
        });

      }else{
      console.log("no image");
      db.close();
      }
    */
          }

        });
      });
    }
  });
    //console.log(req);
});


app.post("/post_message", function (req, res){
  ip = req.headers['x-forwarded-for'] ||
  req.connection.remoteAddress ||
  req.socket.remoteAddress ||
  req.connection.socket.remoteAddress;
  console.log("get post request");
  console.dir(req.body);
  MongoClient.connect("mongodb://localhost/"+settings.db, function(err, db) {
    if (err) { return console.dir(err); }
    db.collection("hierarchy", function(err, collection) {
      var docs = [
        {
          name: req.body.name,
          id: req.body.id,
          contents: req.body.contents,
          my_hierarchy: req.body.my_hierarchy,
          parent_hierarchy: req.body.parent_hierarchy,
          image_num: req.body.image_num,
          red: req.body.red,
          green: req.body.green,
          blue: req.body.blue,
          create_ip: ip,
          create_date: new Date(),
          update_date: new Date(),
          deleted: false
        }
      ]

      collection.insert(docs, function(err, result) {
        //if(err){ res.send("{success: false}") };
        //res.send( "{success: true}" );

        var myRe = /\/.*?\//;
        var myArray = myRe.exec(req.body.my_hierarchy);
        var params = {
          update_date: new Date()
        }
        //console.dir(myArray);
        if(req.body.parent_hierarchy != "/" && req.body.parent_hierarchy.slice(0,1) == "/"){
          var root_hierarchy = myArray[0].slice(0,myArray[0].length-1);
          //console.log(String(myArray[0]).slice(0, String(myArray[1]).length-1));
          console.log(root_hierarchy);
          console.log("root is ue");

          collection.update({ "my_hierarchy" : root_hierarchy }, { $set: params }, function(err, result) {
            if(err){ res.send("{success: false}") };
            res.send( "{success: true}" );
            //current_edit_id = id

            db.close();
          });
        }else{
          db.close();
        }
        //db.close();
      });
    });
  });
});

app.listen(settings.port, settings.host);

const express = require("express");
const admin = require("firebase-admin");
const chokidar = require("chokidar");
const bearerToken = require("express-bearer-token");
const path = require("path");
const app = express();
const port = 8080;

// const serviceAccount = require("./Danceplanet-76cd4b44f069.json");
app.use(bearerToken());
app.use("/public/files", function(req, res, next) {
  admin
    .auth()
    .verifyIdToken(req.token)
    .then(function(decodedToken) {
      // var uid = decodedToken.uid;
      next();
      // ...
    })
    .catch(function(error) {
      // Handle error
      console.error(error);
    });
  // if (req.user) {
  //   next();
  // } else {
  //   res.render(403, "login", { message: "Please, login!" });
  // }
});
app.use(express.static("public/files"));

// TODO: remove this
app.get("/", (req, res) => res.send("Hello World!"));

app.listen(port, () => {
  setupFirebase();
  console.log(`Example app listening on port ${port}!`);
});

const setupFirebase = () => {
  admin.initializeApp();
  var db = admin.firestore();
  // const settings = { timestampsInSnapshots: true };
  // db.settings(settings);

  const watcher = chokidar.watch("./public/files/output/files", {
    ignored: /(^|[\/\\])\../,
    persistent: true
  });

  // Something to use when events are received.
  var log = console.log.bind(console);
  // Add event listeners.
  watcher
    .on("add", path => {
      // const extension = path.extname(path);
      doesPathDocExist(db, path).then(exists => {
        if (!exists) {
          const data = { path: path };
          const setDoc = backendFilesRef(db)
            .doc()
            .set(data);

          log(`File ${path} has been added`);
        }
      });
    })
    .on("change", path => log(`File ${path} has been changed`))
    .on("unlink", path => log(`File ${path} has been removed`));
};

const doesPathDocExist = (db, path) => {
  var col = backendFilesRef(db)
    .where("path", "==", path)
    .limit(1);
  const exists = col
    .get()
    .then(snapshot => {
      let doesDocExist = null;
      snapshot.forEach(doc => {
        if (!doc.exists) {
          console.log("No such document!");
        } else {
          console.log("Document already exists with path: " + doc.data().path);
        }
        doesDocExist = doc.exists;
      });
      return doesDocExist;
    })
    .catch(err => {
      console.log("Error getting document", err);
    });
  return exists;
};

const backendFilesRef = db => {
  const col = db
    .collection("backend")
    .doc("dT0e1A2fT1JFnm2uhKsZ")
    .collection("files");
  return col;
};

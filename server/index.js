const express = require("express");
const mongoose = require("mongoose");
const cors = require("cors");
const authRouter = require("./routes/auth");
const documentRouter = require("./routes/document");

const PORT = process.env.PORT || 3001;

const app = express();
app.use(cors());
app.use(express.json());
app.use(authRouter);
app.use(documentRouter);


const DB = "mongodb+srv://devnidhin2020:Nidhin2020@cluster0.fdnc4cr.mongodb.net/";

mongoose.connect(DB).then(() => {
    console.log("Connected to MongoDB");
});
app.listen(PORT, "0.0.0.0", () => {
    console.log("connecting at port 3001")
});
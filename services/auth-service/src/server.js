const express = require("express");
const cors = require("cors");
require("dotenv").config();

const authRoutes = require("./routes/authRoutes");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
    res.json({
        service: "auth-service",
        status: "healthy"
    });
});

app.use("/api/auth", authRoutes);

const PORT = process.env.PORT || 5001;

app.listen(PORT, () => {
    console.log(`Auth Service running on port ${PORT}`);
});
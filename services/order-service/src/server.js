const express = require("express");
const cors = require("cors");
require("dotenv").config();

const orderRoutes = require("./routes/orderRoutes");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/health", (req, res) => {
    res.json({
        service: "order-service",
        status: "healthy"
    });
});

app.use("/api/orders", orderRoutes);

const PORT = process.env.PORT || 5003;

app.listen(PORT, '0.0.0.0',() => {
    console.log(`Order Service running on port ${PORT}`);
});
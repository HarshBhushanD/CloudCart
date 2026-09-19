const pool = require("../config/db");

// GET all products
const getProducts = async (req, res) => {
    try {
        const result = await pool.query(
            "SELECT * FROM products ORDER BY id ASC"
        );

        res.status(200).json(result.rows);
    } catch (error) {
        console.error("Get products error:", error);

        res.status(500).json({
            message: "Internal server error"
        });
    }
};

// GET product by ID
const getProductById = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            "SELECT * FROM products WHERE id = $1",
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "Product not found"
            });
        }

        res.status(200).json(result.rows[0]);
    } catch (error) {
        console.error("Get product error:", error);

        res.status(500).json({
            message: "Internal server error"
        });
    }
};

// CREATE product
const createProduct = async (req, res) => {
    try {
        const {
            name,
            description,
            price,
            stock
        } = req.body;

        if (!name || price === undefined || stock === undefined) {
            return res.status(400).json({
                message: "Name, price and stock are required"
            });
        }

        const result = await pool.query(
            `INSERT INTO products
            (name, description, price, stock)
            VALUES ($1, $2, $3, $4)
            RETURNING *`,
            [name, description || null, price, stock]
        );

        res.status(201).json({
            message: "Product created successfully",
            product: result.rows[0]
        });
    } catch (error) {
        console.error("Create product error:", error);

        res.status(500).json({
            message: "Internal server error"
        });
    }
};

// UPDATE product
const updateProduct = async (req, res) => {
    try {
        const { id } = req.params;
        const {
            name,
            description,
            price,
            stock
        } = req.body;

        const result = await pool.query(
            `UPDATE products
             SET name = $1,
                 description = $2,
                 price = $3,
                 stock = $4
             WHERE id = $5
             RETURNING *`,
            [name, description, price, stock, id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "Product not found"
            });
        }

        res.status(200).json({
            message: "Product updated successfully",
            product: result.rows[0]
        });
    } catch (error) {
        console.error("Update product error:", error);

        res.status(500).json({
            message: "Internal server error"
        });
    }
};

// DELETE product
const deleteProduct = async (req, res) => {
    try {
        const { id } = req.params;

        const result = await pool.query(
            "DELETE FROM products WHERE id = $1 RETURNING *",
            [id]
        );

        if (result.rows.length === 0) {
            return res.status(404).json({
                message: "Product not found"
            });
        }

        res.status(200).json({
            message: "Product deleted successfully",
            product: result.rows[0]
        });
    } catch (error) {
        console.error("Delete product error:", error);

        res.status(500).json({
            message: "Internal server error"
        });
    }
};

module.exports = {
    getProducts,
    getProductById,
    createProduct,
    updateProduct,
    deleteProduct
};